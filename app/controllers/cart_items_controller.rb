class CartItemsController < ApplicationController
  before_filter :force_full_site
  layout :hyrbrid_layout_nosidebar
  
  # POST /cart_items
  # POST /cart_items.xml
  def create
    flash[:error] = []
    @cart_items = []
    @gift_items = 0
    
    # create cart items
    params[:cart_items].keys.each_with_index do |key,|
      if params[:cart_items][key]['quantity'].to_i > 0
        @cart_item = CartItem.new
        @cart_item.deal_id = params[:cart_items][key]['deal_id'].to_i
        @cart_item.quantity_adding = params[:cart_items][key]['quantity'].to_i
        @cart_item.cart = cart
        
        # gift stuff
        if params[:commit] == Promotion::BUY_AS_GIFT_LABEL or params[:adding_gift] == 'true'
          @cart_item.gift = true
          @cart_item.gift_from = params[:gift_from].blank? ? (current_user ? current_user.customer.name : "") : params[:gift_from]
          @cart_item.gift_name = params[:gift_name]
          @cart_item.gift_email = params[:gift_email]
          @cart_item.gift_message = params[:gift_message]
          @cart_item.gift_send_date = params[:gift_send_date]
          @gift_items += 1 
        end
        
        # add to items array
        @cart_items << @cart_item
      end
    end
    
    if @cart_items.empty?
      flash[:error] = "Please select one of the deal options below."
      redirect_to request.env['HTTP_REFERER'].blank? ? root_url : :back
    elsif @gift_items > 1
      flash[:error] = "Sorry, but you can only add one gift to your cart at the same time. Please add them individually. Thanks!" if params[:tried_once] == 'true'
      redirect_to promotion_path(params[:promotion_id])
    elsif @gift_items == 1 and (!@cart_item.valid_gift? or @cart_item.deal.purchase_limit_remaining(cart, @cart_item.gift_name) < 1)
      flash.now[:error] = "There seems to be a problem. Be sure you complete all of the fields. <br/><br/>Also, you cannot buy a gift for the same person twice or for yourself." if params[:tried_once] == 'true'
      render :action => "new_gift"
    else
      @cart_items.each do |cart_item|
        @existing = CartItem.find(:first, :conditions => {:deal_id => cart_item.deal_id, :cart_id => cart.id, :gift_name => cart_item.gift_name})
        if @existing
          @existing.quantity_adding = cart_item.quantity_adding.to_i
          cart_item = @existing
        end
        
        if cart_item.quantity_adding.to_i > cart_item.deal.purchase_limit_remaining(cart_item.cart, cart_item.gift_name)
          flash[:notice] = "Looks like you tried to add too many of the '#{cart_item.deal.name}' deal to your cart. We've added the maximum amount for you."
          cart_item.quantity = cart_item.deal.purchase_limit
        else
          cart_item.quantity = cart_item.quantity.to_i + cart_item.quantity_adding.to_i
        end
        
        if cart_item.save
          session[:add_to_cart] = true
          session[:added_more_great_deal_to_cart] = params[:added_more_great_deal_to_cart]
      
          if cart_item.deal.early_bird?
            session[:added_early_bird_deal_to_cart] = true
          end
        else
          flash[:error] << cart_item.errors[:base].collect{|e| "#{e}<br/>"}
        end
      end
      
      redirect_to my_cart_path
    end
  end
  
  def edit_gift_item
    @cart_item = CartItem.find(params[:id])
    render :action => 'edit_gift'
  end

  # PUT /cart_items/1
  # PUT /cart_items/1.xml
  def update
    @cart_item = CartItem.find(params[:id])
    @cart_item.quantity = params[:cart_item][:quantity]
    @editing_gift = params[:editing_gift] == 'true'
    
    if @editing_gift 
      @cart_item.gift_from = params[:gift_from]
      @cart_item.gift_name = params[:gift_name]
      @cart_item.gift_email = params[:gift_email]
      @cart_item.gift_message = params[:gift_message]
      @cart_item.gift_send_date = params[:gift_send_date]
    end
       
    if !@editing_gift or @cart_item.valid_gift? and @cart_item.deal.dynamic_purchase_limit(cart,@cart_item.gift_name) > 0 and @cart_item.save
      if @cart_item.quantity.to_i == 0
        flash[:notice] = "#{@cart_item.deal.name} was removed from your cart"
        @cart_item.destroy
      else
        flash[:notice] = 'Quantity updated'
      end
      redirect_to my_cart_path
    else
      flash[:error] = "There was a problem updating your #{@editing_gift ? 'gift' : 'cart item'}. Be sure you complete all the fields.<br><br>Also, you cannot buy a gift for the same person twice or for yourself."
      render :action => 'edit_gift'
    end
  end

  # DELETE /cart_items/1
  # DELETE /cart_items/1.xml
  def destroy
    @cart_item = CartItem.find(params[:id])
    flash[:notice] = "#{@cart_item.deal.name} was removed from your cart" if @cart_item.destroy
    redirect_to my_cart_path
  end
end
