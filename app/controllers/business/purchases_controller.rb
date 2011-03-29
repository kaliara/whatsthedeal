class Business::PurchasesController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_staff_required 
  
  add_template_helper(ApplicationHelper)
  
  # GET /purchases
  # GET /purchases.xml
  def index
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:promotion_id].to_i > 0
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    elsif params[:promotion_id] == 'All'
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    else
      @deals = []
    end

    if params[:q] =~ /\d+\-?/
      @type = "Confirmation Code"
      @coupons = Coupon.find_by_confirmation_code(params[:q]).to_a
    elsif params[:q] =~ /\w+/
      @type = "Last Name"
      @user_ids = Customer.find(:all, :conditions => ['last_name like ?', "%#{params[:q]}%"]).collect{|c| c.user.id}
      @coupons = Coupon.find(:all, :conditions => {:user_id => @user_ids, :deal_id => @deals}, :order => 'confirmation_code ASC')
    elsif params[:all] == 'yes'
      @coupons = Coupon.find(:all, :conditions => {:deal_id => @deals}, :order => 'confirmation_code ASC')
    else
      @coupons = []
    end    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
    end
  end
  
  def mobile_redemptions
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    @start_date = params[:start_date].nil? ? DateTime.parse(Date.commercial(Date.today.year, Date.today.cweek, 1).strftime("%m/%d/%Y") + " 04:00:00") : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.parse(Date.commercial(Date.today.year, Date.today.cweek, 7).strftime("%m/%d/%Y") + " 04:00:00") : DateTime.parse(params[:end_date] + " 04:00:00")
    
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:promotion_id].to_i > 0
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    elsif params[:promotion_id] == 'All'
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    else
      @deals = [Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten.first]
      @default_promotion = Deal.find(@deals.first).promotion
    end

    @coupons = Coupon.find(:all, :conditions => ['deal_id in (?) and mobile_used = ? and redemption_date >= ? and redemption_date < ?', @deals.join(','), true, @start_date, @end_date + 1.day], :order => 'redemption_date ASC')
    
    render :action => 'mobile_redemptions'
  end

  # GET /purchases/1
  # GET /purchases/1.xml
  def show
    @purchase = Purchase.find(params[:promotion_id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase }
    end
  end
  
  # export to .xls
  def export
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:promotion_id].to_i > 0
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    else
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
    end
    @coupons = Coupon.find(:all, :conditions => {:deal_id => @deals}, :order => 'deal_id ASC')

    @path = "dc/biz_exports/" + (user.business.name.downcase.gsub(/[\s+|\W+]/, '')) + '_coupons_' + Time.zone.now.strftime("%m%d%y%H%M") + ".xls"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    sheet1.row(0).push "Purchaser Name", "Confirmation Code", "Date Purchased", "Deal", "Purchase Price", "Redeemed?", "Coupon Code"
    @coupons.each_with_index do |coupon,i|
      sheet1.row(i+1).push coupon.recipient, coupon.confirmation_code, coupon.created_at.strftime("%b %e, %Y"), coupon.name, Object.new.extend(ActionView::Helpers::NumberHelper).number_to_currency(coupon.deal.price), (coupon.biz_used? ? 'Yes' : ''), coupon.coupon_code
    end

    format = Spreadsheet::Format.new :weight => :bold, :size => 18
    sheet1.row(0).default_format = format
    
    book.write "public/system/assets/" + @path
    
    render :action => 'export'
  end
  
  # mark many coupons as used
  def bulk_use
    unless params[:coupons].nil?
      @coupons = Coupon.find(params[:coupons].keys.to_a)
      @coupons.each do |coupon|
        coupon.biz_used = true
        coupon.redemption_date = Time.now if coupon.redemption_date.nil?
        coupon.save
      end
    else
      flash[:error] = "Please select one or more purchases to mark as redeemed"
    end
    
    redirect_to :action => 'index', :promotion_id => params[:promotion_id], :q => params[:q]
  end

end