class Admin::CouponsController < ApplicationController
  layout 'admin', :except => :show
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /coupons
  # GET /coupons.xml
  def index
    if params[:q] =~ /\@/
      @type = "Email"
      @coupons = Coupon.find(:all, :conditions => {:user_id => User.find_by_email(params[:q]).id}, :order => 'created_at DESC')
    elsif params[:q] =~ /\d+\-?/
      @type = "Confirmation Code"
      @coupons = Coupon.find_by_confirmation_code(params[:q]).to_a
    else
      @coupons = Coupon.find(:all, :order => 'created_at DESC', :limit => 20, :offset => params[:offset].to_i)
    end
    
    
    respond_to do |format|
      format.html { }
      format.xml  { head :ok }
    end
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    @coupon = Coupon.find(params[:id])
    
    respond_to do |format|
      format.html { }
      format.xml  { head :ok }
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.xml
  def destroy
    @coupon = Coupon.find(params[:id])
    @purchase = @coupon.purchase
    @difference = @purchase.total - @coupon.deal.price

    # update purchase totals
    @purchase.deals_total = @purchase.deals_total - @coupon.deal.price
    @purchase.total = [0, @difference].max
    @purchase.save
    
    # destroy coupon and empty purchases
    if @coupon.destroy
      flash[:notice] = "Coupon has been removed, double check the purchase to verify: <a href='#{admin_purchase_path(@purchase)}'>view purchase</a>"
    end
    if @purchase.coupons.empty?
      @purchase.destroy
      flash[:notice] = "Coupon and entire purchase (since it only had one coupon) has been removed."
    end
    
    # differnce credit needed?
    if @difference < 0
      @credit = Credit.new
      @credit.promotion_code_id = PromotionCode::DIFFERENCE_CREDIT
      @credit.value = @difference.abs
      @credit.user_id = @coupon.user.id
      @credit.save
      flash[:notice] += "<br/>Also, we credited the users account $#{@credit.value} because the new purchase price (or removed purchase) means they would have had credit left over.<br/><a href='#{admin_impersonate_path(:type => 'customer', :id => @credit.user.customer.id)}'>Impersonate this customer</a> to make sure everything is in order."
    end
    
    respond_to do |format|
      format.html { redirect_to admin_coupons_path }
      format.xml  { head :ok }
    end
  end
  
  # Activate and send out coupon
  def activate_coupons
    @coupon = Coupon.find(params[:id])
    if @coupon.deal.promotion.quota_met? and !@coupon.emailed?
      @coupon.activate!
      @coupon.emailed!
      #Notifier.deliver_coupons_ready_notification(@coupon.user, [@coupon])
      flash[:notice] = "Coupon has been activated for #{@coupon.user.customer.name} (#{@coupon.user.email})"
    else
      flash[:error] = "This coupon is part of the promotion that hasn't met it's quota. I refuse to activate it."
    end
    redirect_to admin_coupons_path
  end
end