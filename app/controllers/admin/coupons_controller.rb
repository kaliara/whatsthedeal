class Admin::CouponsController < ApplicationController
  layout 'admin', :except => :show
  before_filter :staff_required
  
  # GET /coupons
  # GET /coupons.xml
  def index
    if params[:q] =~ /\@/
      @type = "Email"
      @coupons = Coupon.find(:all, :conditions => {:user_id => User.find_by_email(params[:q]).id}, :order => 'created_at DESC')
    elsif params[:q] =~ /\d+/
      @type = "Confirmation Code"
      @coupons = Coupon.find(:all, :conditions => ["REPLACE(confirmation_code,'-','') = '#{params[:q].gsub(/\-/,'')}'"]).to_a
    elsif params[:q] =~ /\w+/
      @type = "Name"
      @user_ids = Customer.find(:all, :conditions => ['first_name like ? or last_name like ? or CONCAT(first_name," ",last_name) like ?', "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%"]).collect{|c| c.user.id}
      @coupons = Coupon.find(:all, :conditions => {:user_id => @user_ids}, :order => 'confirmation_code ASC')
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
    @user = @coupon.user
    @difference = @purchase.total - @coupon.deal.price

    # update purchase totals
    @purchase.deals_total = @purchase.deals_total - @coupon.deal.price
    @purchase.total = [0, @difference].max
    @purchase.save

    # destroy coupon and empty purchases
    if @coupon.delete!
      flash[:notice] = "Coupon has been voided, double check the purchase to verify: <a href='#{admin_purchase_path(@purchase)}'>view purchase</a>"

      if @purchase.coupons.empty?
        @purchase.delete!
        flash[:notice] = "Coupon has been voided. The purchase was voided as well (since it only contained that one coupon)"
      end

      # differnce credit needed?
      if @difference < 0
        @credit = Credit.new
        @credit.promotion_code_id = PromotionCode::DIFFERENCE_CREDIT
        @credit.value = @difference.abs
        @credit.user_id = @user.id
        @credit.save
        flash[:notice] += "<br/>Also, we credited the users account $#{@credit.value} because the new purchase price (or removed purchase) means they would have had credit left over.<br/><a href='#{admin_impersonate_path(:type => 'customer', :id => @credit.user.customer.id)}'>Impersonate this customer</a> to make sure everything is in order."
      end
      
      # create a void entry if necessary
      if Void.find_by_purchase_id(@purchase.id)
        @void = Void.find_by_purchase_id(@purchase.id)
        @void.processed = false
      else
        @void = Void.new
        @void.purchase_id = @purchase.id
      end
      @void.save
      flash[:notice] += "<br/><br/>An entry has been created in the Voids table and will be processed at 5pm. <a href='/admin/voids/#{@void.id}'>View the Void entry</a>."
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