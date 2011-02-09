class PartnerPurchasesController < ApplicationController
  layout 'teampick'

  def home
    @promotion = Promotion.featured.empty? ? Promotion.first : Promotion.featured.first
    @cart_item = CartItem.new
  end
  
  def checkout
    @promotion = Promotion.featured.empty? ? Promotion.first : Promotion.featured.first
    @cart_item = CartItem.new
  end
  
  def new
    @purchase = Purchase.new
  end

  def create
    # create purchase with params
    @purchase = Purchase.new(params[:purchase])
    @purchase.partner_id = 1
    
    # quickly create user
    @user = User.find_or_create_by_email(params[:purchase][:customer_email])
    
    if @user.new_record?
      @user.password = Digest::MD5.hexdigest(params[:purchase][:customer_email])
      @user.password_confirmation = Digest::MD5.hexdigest(params[:purchase][:customer_email])
      @user.origin_id = Origin.find_by_code('sloopy').id
    end
    
    if (params[:purchase][:customer_email] != params[:customer_email_confirm]) or !@user.save
      flash.now[:error] = "There was a problem with your email address. Please try again."
      render :action => "new"
    else
      # quickly create customer unelss we find one
      unless @user.customer?
        @customer = Customer.new
        @customer.first_name = @purchase.first_name
        @customer.last_name = @purchase.last_name
        @customer.user_id = @user.id
        @customer.save
      end
      
      @cart = cart
      @cart.user_id = @user.id

      @purchase.user_id = @user.id
      @purchase.total = @cart.total
      @purchase.deals_total = @cart.deals_total

      if @purchase.save
        # build coupons
        @purchase.build_coupons(cart)

        # empty cart
        @cart.empty!
        
        # track purchase
        session[:new_purchase] = true

        render :action => 'show'

        # would like to have done this as an :after_create callback, but causes problems
        Notifier.deliver_sloopy_purchase_confirmation(@purchase.user, @purchase)
      else
        render :action => "new"
      end
    end
  
  end
  
  def add_to_cart
    flash[:error] = []

    params[:cart_items].keys.each do |key|
      if params[:cart_items][key]['quantity'].to_i > 0
        
        # create cart item
        @cart_item = CartItem.new
        @cart_item.deal_id = params[:cart_items][key]['deal_id'].to_i
        @cart_item.quantity = params[:cart_items][key]['quantity'].to_i
        @cart_item.cart_id = cart.id

        # check for existing quantity
        @existing = CartItem.find(:first, :conditions => {:deal_id => @cart_item.deal_id, :cart_id => cart.id})
        if @existing
          @cart_item = @existing
          @cart_item.quantity += params[:cart_items][key]['quantity'].to_i
        end

        # respond_to do |format|
        if @cart_item.save
          redirect_to :action => 'new'
        else
          flash[:error] = "Silly rabbit. You already have this deal in your cart. <a href='/partner_purchases/new'>Click here to checkout</a>."
          redirect_to :action => 'home'
        end
        
      end
    end
  end
  
  def empty_cart
    cart.empty!
    
    redirect_to :action => 'home'
  end
  
  def show
    @purchase = Purchase.find(params[:id])
  end
end