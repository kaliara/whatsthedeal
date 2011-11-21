class CouponsController < ApplicationController
  layout :hyrbrid_layout_nosidebar, :except => [:show, :show_gift, :show_direct]
  
  before_filter :impersonate_customer
  before_filter :customer_required, :except => [:bulk_use, :legacy, :show_gift, :show_direct]
  before_filter :business_required, :only => [:bulk_use]

  # GET /coupons
  # GET /coupons.xml
  def index
    @on_my_account = true
    session[:force_full_site] = false
    
    case @show_all = params[:show_all].nil? ? "unused" : params[:show_all]
    when 'used'
      @coupons = current_user.coupons.used.delete_if{|c| c.expired?}
    when 'expired'
      @coupons = current_user.coupons.delete_if{|c| !c.expired?}
    when 'gifts'
      @coupons = current_user.coupons.gifts
    else
      @coupons = current_user.coupons.unused.delete_if{|c| c.expired?}
    end
    
    render :action => 'index'
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    @on_my_account = true
    session[:force_full_site] = false
    
    @coupon = Coupon.find(params[:id])
    
    if @coupon.shippable?
      flash.now[:error] = "Sorry, but this is a physical coupon that we have mailed to you, So you can't view or print it."
      redirect_to my_deals_path
    elsif !@coupon.stolen?(current_user)
      flash.now[:notice] = "Remember, You can only use each coupon one time." if @coupon.printed?
      @coupon.printed! unless @coupon.printed?
      render :action => 'show'
    else
      redirect_to my_deals_path
    end
  end
  
  def show_direct
    @coupon = Coupon.find_by_access_token(params[:access_token])
    unless @coupon.nil?
      @coupon.printed! unless @coupon.printed?
      render :action => 'show'
    else
      redirect_to :back
    end
  end
        
  def shipping_details
    @on_my_account = true
    session[:force_full_site] = false
    
    @coupon = Coupon.find(params[:id])
    @purchase = @coupon.purchase
    
    unless @coupon.stolen?(current_user)
      render :action => 'shipping_details'
    else
      redirect_to my_deals_path
    end
  end
  
  def show_gift
    @on_my_account = true
    session[:force_full_site] = false
    
    @coupon = Coupon.find_by_gift_access_token(params[:token])
    
    if params[:token].blank? or @coupon.nil?
      redirect_to root_url 
    elsif @coupon.shippable?
      flash.now[:error] = "Sorry, but this is a physical coupon that we have mailed to you, So you can't view or print it."
      redirect_to my_deals_path
    else
      @coupon.printed!
      render :action => 'show'
    end
  end
  
  def edit_gift
    @on_my_account = true
    @coupon = Coupon.find(params[:id])
    
    if @coupon.stolen?(current_user) or @coupon.emailed?
      flash[:error] = "Sorry, but this gift cannot be modified."
      redirect_to my_deals_path
    end
  end

  def update_gift
    @on_my_account = true
    @coupon = Coupon.find(params[:id])
    
    # protect from unauthorized changes
    @coupon.gift_from = params[:gift_from]
    @coupon.gift_name = params[:gift_name]
    @coupon.gift_email = params[:gift_email]
    @coupon.gift_message = params[:gift_message]
    @coupon.gift_send_date = params[:gift_send_date]
    
    if @coupon.valid_gift? and @coupon.save
      flash[:notice] = "Your gift information has been updated."
      redirect_to my_deals_gifts_path
    else
      flash[:error] = "There seems to be a problem. Be sure you complete all the fields.<br/><br/>Also, you cannot give a gift to the same person twice or to yourself."
      render :action => 'edit_gift'
    end
  end
  
  def update
    @on_my_account = true
    @coupon = Coupon.find(params[:id])
    @coupon.used = params[:coupon][:used]
    
    if mobile and !@coupon.mobile_used? and params[:coupon][:used] == 'true'
      @coupon.mobile_used = true
      @coupon.biz_used = true
      @coupon.redemption_date = Time.now
    end
    
    @coupon.save
    
    case @show_all = params[:show_all]
    when 'used'
      redirect_to my_deals_used_path
    when 'expired'
      redirect_to my_deals_expired_path
    when 'expired'
      redirect_to my_deals_path
    else
      redirect_to coupon_path(@coupon)
    end
  end

  # business bulk update
  def legacy
    redirect_to "http://wtd.heroku.com/deal/access/#{params[:deal_id]}/#{params[:user_id]}/"
  end
  
end