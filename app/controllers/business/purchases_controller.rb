class Business::PurchasesController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_staff_required 
  
  add_template_helper(ApplicationHelper)
  
  # GET /purchases
  # GET /purchases.xml
  def index
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @deals = []
    @kgb_deals = []
    @coupons = []
    @kgb_coupons = []
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:promotion_id].to_i > 0
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
      @kgb_deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.kgb_deal_id}}.flatten
    elsif params[:promotion_id] == 'All'
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
      @kgb_deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.kgb_deal_id}}.flatten
    end

    if params[:q] =~ /\d/
      @type = "Confirmation Code"
      @deals = [0] if @deals.empty?
      @kgb_deals = [0] if @kgb_deals.empty?
      @coupons = Coupon.find(:all, :conditions => ["REPLACE(confirmation_code,'-','') = '#{params[:q].gsub(/\-/,'')}' and deal_id in (#{@deals.join(',')})"]).to_a
      @kgb_coupons = KgbCoupon.find(:all, :conditions => ["transactions_transaction_id like ? and transactions_deal_id in (#{@kgb_deals.join(',')})", "%#{params[:q]}%"]).to_a
    elsif params[:q] =~ /\w+/
      @type = "Name"
      @user_ids = Customer.find(:all, :conditions => ['first_name like ? or last_name like ? or CONCAT(first_name," ",last_name) like ?', "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%"]).collect{|c| c.user.id}
      @coupons = Coupon.find(:all, :conditions => {:user_id => @user_ids, :deal_id => @deals}, :order => 'confirmation_code ASC')
      @kgb_coupons = KgbCoupon.find(:all, :conditions => ["(users_first_name like ? or users_last_name like ? or CONCAT(users_first_name,' ',users_last_name) like ?) and transactions_deal_id in (#{@kgb_deals.join(',')})", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%"], :order => 'transactions_transaction_id ASC')
    elsif params[:all] == 'yes'
      @coupons = Coupon.find(:all, :conditions => {:deal_id => @deals}, :order => 'confirmation_code ASC')
      @kgb_coupons = KgbCoupon.find(:all, :conditions => {:transactions_deal_id => @kgb_deals}, :order => 'transactions_transaction_id ASC')
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
    end

    @coupons = Coupon.find(:all, :conditions => ['deal_id in (?) and mobile_used = ? and redemption_date >= ? and redemption_date < ?', @deals.join(','), true, @start_date, @end_date + 1.day], :order => 'redemption_date ASC')
    
    render :action => 'mobile_redemptions'
  end
  
  
  def stats
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:promotion_id].to_i > 0
      @promotion = Promotion.find(params[:promotion_id])
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
      @coupons = Coupon.find(:all, :conditions => {:deal_id => @deals}, :order => 'created_at ASC')
      @customers = Customer.find(:all, :conditions => {:user_id => @coupons.collect{|c|c.user_id}})
      
      @males = Customer.find(:all, :conditions => ["female = 0 and id in (#{@customers.collect{|c| c.id}.join(',')})"])
      @females = Customer.find(:all, :conditions => ["female = 1 and id in (#{@customers.collect{|c| c.id}.join(',')})"])
      @neither = Customer.find(:all, :conditions => ["female is null and id in (#{@customers.collect{|c| c.id}.join(',')})"])
      
      @zipcodes = @customers.collect{|c| c.zipcode}.delete_if{|z|z.blank?}.uniq
      @zipcode_purchases = {}
      @zipcodes.each do |zipcode|
        @zipcode_purchases[zipcode] = Customer.find(:all, :conditions => {:id => @customers, :zipcode => zipcode}).size
      end
      @zipcode_purchases = @zipcode_purchases.sort {|a,b| b[1] <=> a[1]}
    else
      @deals = []
    end

    @line_items = []
    
    unless @deals.empty? or @promotion.nil?
      @first_day = DateTime.new(@coupons.first.created_at.year,@coupons.first.created_at.month,@coupons.first.created_at.day)
      @last_day  = DateTime.new(@coupons.last.created_at.year, @coupons.last.created_at.month, @coupons.last.created_at.day)
      @days = (@last_day - @first_day)
      for i in 0..@days+1 do
        @line_items[i] = Coupon.find(:all, :conditions => ["deal_id in (#{@deals.join(',')}) and created_at >= ? and created_at < ?", (@first_day + i.days), (@first_day + (i+1).days)]).size
      end
    end

    render :action => 'stats'
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
    @wtd_coupons = []
    @kgb_coupons = []
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:excel_promotion_id].to_i > 0
      @deals     = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:excel_promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
      @kgb_deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:excel_promotion_id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.kgb_deal_id}}.flatten
    else
      @deals     = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
      @kgb_deals = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.kgb_deal_id}}.flatten
    end
    @wtd_coupons = Coupon.find(:all, :conditions => {:deal_id => @deals}, :order => 'deal_id ASC')
    @kgb_coupons = KgbCoupon.find(:all, :conditions => {:transactions_deal_id => @kgb_deals}, :order => 'transactions_deal_id ASC')
    @coupons = @wtd_coupons + @kgb_coupons

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
    if params[:coupons].nil? and params[:kgb_coupons].nil?
      flash[:error] = "Please select one or more purchases to mark as redeemed"
    else
      unless params[:coupons].nil?
        @coupons = Coupon.find(params[:coupons].keys.to_a)
        @coupons.each do |coupon|
          coupon.biz_used = true
          coupon.redemption_date = Time.now if coupon.redemption_date.nil?
          coupon.save
        end
      end
      unless params[:kgb_coupons].nil?
        @kgb_coupons = KgbCoupon.find(params[:kgb_coupons].keys.to_a)
        @kgb_coupons.each do |coupon|
          coupon.biz_used = true
          coupon.redemption_date = Time.now if coupon.redemption_date.nil?
          coupon.save
        end
      end
    end
    
    redirect_to :action => 'index', :promotion_id => params[:promotion_id], :q => params[:q]
  end

end