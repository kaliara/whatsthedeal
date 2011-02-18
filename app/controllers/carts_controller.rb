class CartsController < ApplicationController
  before_filter :impersonate_customer
  layout :hyrbrid_layout_nosidebar, :only => :show
  
  # GET /carts/1
  # GET /carts/1.xml
  def show
    if current_user
      redirect_to new_purchase_path
    else
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
        @other_promotions = @promotions.empty? ? [] : Promotion.find(:all, :conditions => ["id in (#{@promotions}) and end_date > ? and active = ? and hidden = ?", Time.zone.now, true, false], :limit => 3, :order => "end_date ASC")

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
    
      render :action => 'show'
    end
  end

  # POST /carts
  # POST /carts.xml
  def create
    @cart = Cart.new(params[:cart])

    respond_to do |format|
      if @cart.save
        format.html { redirect_to(@cart) }
        format.xml  { render :xml => @cart, :status => :created, :location => @cart }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cart.errors, :status => :unprocessable_entity }
      end
    end
  end

end