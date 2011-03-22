class Business::PurchaseStatsController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_staff_required 
  
  # GET /purchase_stats
  # GET /purchase_stats.xml
  def show
    user = current_user.business? ? current_user : current_user.business_staff.business.user
    @business_ids = Business.find(:all, :conditions => {:user_id => user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids})
    
    if params[:id].to_i > 0
      @promotion = Promotion.find(params[:id])
      @deals = Promotion.find(:all, :conditions => {:business_id => @business_ids, :id => params[:id].to_i}, :order => 'id DESC').collect{|a|a.deals.collect{|d|d.id}}.flatten
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
      puts @zipcode_purchases.to_yaml
      @zipcode_purchases = @zipcode_purchases.sort {|a,b| b[1] <=> a[1]}
      puts @zipcode_purchases.to_yaml
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

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deals }
    end
  end
end