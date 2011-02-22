class PurchasesController < ApplicationController
  include ActiveMerchant::Utils

  before_filter :impersonate_customer
  before_filter :customer_required
  layout :hyrbrid_layout_nosidebar

  # GET /purchases/1
  # GET /purchases/1.xml
  def show
    @purchase = Purchase.find(:first, :conditions => {:id => params[:id], :user_id => current_user.id})
    @track_transaction = false
    @on_purchase = true
    
    @mapped_promotions   = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, true], :order  => 'featured DESC, start_date DESC')
    @unmapped_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, false], :order  => 'featured DESC, start_date DESC')

    if !cookies[:location_latitude].blank? and !cookies[:location_longitude].blank?
      session[:location_latitude]  = cookies[:location_latitude] 
      session[:location_longitude] = cookies[:location_longitude]
    elsif current_user and !current_user.customer.latitude.blank? and !current_user.customer.longitude.blank?
      session[:location_latitude]  = current_user.customer.latitude
      session[:location_longitude] = current_user.customer.longitude
    end
    
    if @purchase.nil?
      flash[:error] = 'Sorry, but we couldn\'t find that purchase.'
      redirect_to  my_deals_path
    else
      flash.now[:notice] = "The coupon you selected is in <strong>orange</strong> below." if params[:coupon]
      render :action => 'show'
    end
  end

  # GET /purchases/new
  # GET /purchases/new.xml
  def new
    @on_purchase = true
    
    # cart checks
    flash.now[:error] = "A deal in your cart was sold out, so we had to remove it. Sorry! <br/><br/>Refresh the page or <a href='/my_cart'>click here</a> to view your updated cart." if cart.remove_soldout_deals?
    flash.now[:error] = "There were some interesting gifts in your cart. We had to removed them to make sure everything checks out. Now that your logged in, you can try adding them again. <br/><br/>Refresh the page or <a href='/my_cart'>click here</a> to view your updated cart." if cart.remove_invalid_gifts?
    flash.now[:error] = "There was a deal in your cart that you already purchased the maximum for, so we had to remove it. Sorry!" if cart.remove_already_purchased_maximum_deals?
    @cart_item = CartItem.new
    
    # show other deals not in cart
    if cart.empty?
      @other_promotions = Promotion.find(:all, :conditions => ["end_date > ? and active = ? and hidden = ?", Time.zone.now, true, false], :limit => 3, :order => "end_date ASC")
    else
      @cart_deals = Deal.find(:all, :conditions => ["id in (#{cart.cart_items.collect{|ci| ci.deal_id}.join(',')})"]).collect{|d| d.promotion_id}.join(',')
      @promotions = Promotion.find(:all, :conditions  => ["id not in (#{@cart_deals})"]).delete_if{|p| !p.active? or p.sold_out?}.collect{|p| p.id}.join(',')
      @other_promotions = @promotions.empty? ? [] : Promotion.find(:all, :conditions => ["id in (#{@promotions}) and end_date > ? and active = ? and hidden = ?", Time.zone.now, true, false], :limit => 4, :order => "end_date ASC")

      # update credits
      if current_user and !current_user.credits.redeemable.empty?
        if cart.has_credit_restricted_promotion?
          flash[:error] = "Sorry, one of the deals in your cart cannot be purchased with credit"
        else
          current_user.credits.redeemable.each do |credit|
            credit.cart_id = cart.id
            flash[:error] = credit.errors.on(:promotion_code).to_s + credit.errors.on(:referral).to_s + credit.errors.on(:user).to_s unless credit.save
          end
          cart.save
        end
      end
    end

    if cart.remove_invalid_gifts?
      flash[:error] = "There were some invalid gifts in your cart. We had to remove them to make sure everything checks out. Now that your logged in, you can try adding them again. <br/><br/>Refresh the page or <a href='/my_cart'>click here</a> to view your updated cart."
      redirect_to new_purchase_path and return
    elsif cart.remove_soldout_deals?
      flash[:error] = "A deal in your cart was sold out, so we had to remove it. Sorry! <br/><br/>Refresh the page or <a href='/my_cart'>click here</a> to view your updated cart."
      redirect_to new_purchase_path and return
    end
      
    @user = current_user
    @purchase = Purchase.new
    @credit = Credit.new
    @store_billing_info = true
    @update_shipping_info = true
    @last_credit = current_user.credits.last unless current_user.credits.redeemable.empty?
    
    # setup typical purchase process if need to charge credit card
    if cart.total > 0
      # update credits
      if current_user and !current_user.credits.redeemable.empty?
        if cart.has_credit_restricted_promotion?
          flash[:error] = "Sorry, one of the deals in your cart cannot be purchased with credit"
        else
          current_user.credits.redeemable.each do |credit|
            credit.cart_id = cart.id
            flash[:error] = credit.errors.on(:promotion_code).to_s + credit.errors.on(:referral).to_s + credit.errors.on(:user).to_s unless credit.save
          end
          cart.save
        end
      end
      
      # create customer profile if none exists
      unless @user.customer_cim_id.to_i > 0
        unless @user.create_cim_profile
          flash[:error] = 'There seems to be a problem with your account. <br><br>Please <strong>email support@sowhatsthedeal.com noting that you saw the "DUPLICATE CIM ID" error</strong> before attempting to make a purchase.'
        end
      end
      
      # create a new payment profile unless one exists
      if @user.payment_profile.nil? or (@user.payment_profile.payment_cim_id.to_i == 0)
        @purchase.payment_profile = PaymentProfile.new
      else
        @purchase.payment_profile = @user.payment_profile
        @existing_payment_profile = @user.payment_profile
      end
    end
    render :action => 'new'
  end

  # POST /purchases
  # POST /purchases.xml
  def create
    @mapped_promotions   = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, true], :order  => 'featured DESC, start_date DESC')
    @unmapped_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, false], :order  => 'featured DESC, start_date DESC')
    
    unless cart.empty?
      @user = current_user
      @store_billing_info   = params[:store_billing_info].to_i == 0 ? false : true
      @update_shipping_info = params[:update_shipping_info].to_i == 0 ? false : true
      @track_transaction = false
              
      @purchase = Purchase.new
      @purchase.invoice_number = params[:purchase][:invoice_number]
      @purchase.description    = params[:purchase][:description]
      @purchase.user_id        = @user.id
      @purchase.total          = cart.total.to_f
      @purchase.deals_total    = cart.deals_total.to_f
      @purchase.partner_id     = partner

      if cart.shippable_item?
        @purchase.shipping_name     = params[:user][:customer][:shipping_name]
        @purchase.shipping_address1 = params[:user][:customer][:shipping_street1]
        @purchase.shipping_address2 = params[:user][:customer][:shipping_street2]
        @purchase.shipping_city     = params[:user][:customer][:shipping_city]
        @purchase.shipping_state    = params[:user][:customer][:shipping_state]
        @purchase.shipping_zipcode  = params[:user][:customer][:shipping_zipcode]
      end
      
      if @update_shipping_info
        @user.customer.shipping_name    = params[:user][:customer][:shipping_name]
        @user.customer.shipping_street1 = params[:user][:customer][:shipping_street1]
        @user.customer.shipping_street2 = params[:user][:customer][:shipping_street2]
        @user.customer.shipping_city    = params[:user][:customer][:shipping_city]
        @user.customer.shipping_state   = params[:user][:customer][:shipping_state]
        @user.customer.shipping_zipcode = params[:user][:customer][:shipping_zipcode]
        @user.save
      end

      if @purchase.total > 0
        if @user.payment_profile.nil? or (@user.payment_profile.payment_cim_id.to_i == 0)
          @purchase.payment_profile = PaymentProfile.new
          @purchase.payment_profile.user_id = @user.id
          @purchase.payment_profile.credit_card = {
          :number             => params[:purchase][:payment_profile_attributes][:credit_card][:number],
          :verification_value => params[:purchase][:payment_profile_attributes][:credit_card][:verification_value],
          :month              => params[:purchase][:payment_profile_attributes][:credit_card][:month],
          :year               => params[:purchase][:payment_profile_attributes][:credit_card][:year],
          :first_name         => params[:purchase][:payment_profile_attributes][:credit_card][:first_name],
          :last_name          => params[:purchase][:payment_profile_attributes][:credit_card][:last_name],
          }
        
          @purchase.payment_profile.billing_address = {
            :first_name => params[:purchase][:payment_profile_attributes][:credit_card][:first_name],
            :last_name  => params[:purchase][:payment_profile_attributes][:credit_card][:last_name],
        
            :address1   => params[:purchase][:payment_profile_attributes][:billing_address][:address1],
            :address2   => params[:purchase][:payment_profile_attributes][:billing_address][:address2],
            :city       => params[:purchase][:payment_profile_attributes][:billing_address][:city],
            :state      => params[:purchase][:payment_profile_attributes][:billing_address][:state],
            :country    => "US",
            :zip        => params[:purchase][:payment_profile_attributes][:billing_address][:zip],
          }
    
          unless @purchase.payment_profile.save
            @credit = Credit.new
            flash.now[:error] = @purchase.payment_profile.errors.on(:profile).to_s unless @purchase.payment_profile.errors.on(:profile).blank?

            # create a new payment profile unless one exists
            if @user.payment_profile.nil? or (@user.payment_profile.payment_cim_id.to_i == 0)
              @purchase.payment_profile = PaymentProfile.new
            else
              @purchase.payment_profile = @user.payment_profile
              @existing_payment_profile = @user.payment_profile
            end

            render :action => 'new' and return
          end
        else
          @purchase.payment_profile = @user.payment_profile
        end
        
        if cart.shippable_item? and (params[:user][:customer][:shipping_name].blank? or params[:user][:customer][:shipping_street1].blank? or params[:user][:customer][:shipping_city].blank? or params[:user][:customer][:shipping_state].blank? or params[:user][:customer][:shipping_zipcode].size < 5)
          @credit = Credit.new
          
          # create a new payment profile unless one exists
          if @user.payment_profile.nil? or (@user.payment_profile.payment_cim_id.to_i == 0)
            @purchase.payment_profile = PaymentProfile.new
          else
            @purchase.payment_profile = @user.payment_profile
            @existing_payment_profile = @user.payment_profile
          end
          
          @user.customer.errors.add_to_base "Please fill out a complete shipping address"
          flash.now[:error] = "One or more of your deals requires a shipping address. Please fill out a complete shipping address."
          render :action => 'new' and return
        end
      end
      
      # try to save the purchase AND process the new payment profile
      if (@purchase.total == 0 or !@purchase.payment_profile.nil?) and @purchase.save
        # build coupons
        @purchase.build_coupons(cart)
      
        # generate difference credit
        cart.reconcile_credit
      
        # redeem credits
        cart.credits.each do |credit|
          credit.redeem!(@purchase)
        end
      
        # trigger analytics tracking
        session[:new_purchase] = true    
        @track_transaction = true
          
        # empty cart
        cart.empty!
        cart.save
      
        # update user's name if necessary
        if @user.customer.first_name.blank? or @user.customer.first_name == Customer::STOCK_FIRST_NAME
          if params[:purchase][:first_name].blank?
            @user.customer.first_name = params[:purchase][:payment_profile_attributes][:credit_card][:first_name]
            @user.customer.last_name  = params[:purchase][:payment_profile_attributes][:credit_card][:last_name]
          else
            @user.customer.first_name = params[:purchase][:first_name]
            @user.customer.last_name  = params[:purchase][:last_name]
          end

          @user.save
        end
        
        # delete the payment profile unless user wants it saved
        if !@store_billing_info and @purchase.total > 0
          @purchase.payment_profile.destroy
        end
        
        if @purchase.send_purchase_confirmation
          flash.now[:notice] = 'Thanks for purchasing from What\'s The Deal!'
          render :action => 'show'
        else
          redirect_to timeout_error_path
          flash[:error] = "<strong>Don't worry, your purchase was made successfully!</strong>  We just had trouble sending your purchase confirmation email. If you'd like us to manually send the confirmation email, let us know at <a href='mailto:support@sowhatsthedeal.com'>support@sowhatsthedeal.com</a>."
        end
      else
        # delete the payment profile because we assume something is wrong with it
        @credit = Credit.new
        @purchase.payment_profile.destroy unless (@purchase.payment_profile.nil? and @user.payment_profile.nil?)
        # create a new payment profile unless one exists
        if @user.payment_profile.nil? or (@user.payment_profile.payment_cim_id.to_i == 0)
          @purchase.payment_profile = PaymentProfile.new
        else
          @purchase.payment_profile = @user.payment_profile
          @existing_payment_profile = @user.payment_profile
        end
        #flash.now[:error] = @purchase.errors.on(:base).nil? ? "22There seems to be a problem with your payment information." : @purchase.errors.on(:base).to_s
        render :action => 'new' and return
      end
    else
      flash[:error] = "Sorry, but your cart was empty while you were trying to checkout. Please try adding the deal to your cart again."
      redirect_to root_url
    end
  end
end