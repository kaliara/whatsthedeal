class Admin::DashboardsController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  def index
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    @start_date = params[:start_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:end_date] + " 04:00:00")

    @partner_id = params[:partner_id].to_i

    @registrations = User.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day])
    @referrals = User.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day]).delete_if{|u| Credit.find(:all, :conditions => ["user_id = ? and referrer_user_id > 0", u.id]).size == 0}
    @subscriptions = User.find(:all, :conditions => ["created_at >= ? and created_at < ? and gets_daily_deal_email = ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day, true])
    @purchases = Purchase.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day])
    @first_purchases = Purchase.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ["user_id = ?", p.user_id], :order => "created_at ASC").id}
    @deals = @purchases.collect{|p| p.coupons}.flatten
    @revenue = @purchases.collect{|p| p.deals_total}.sum
    @revenue_post_credit = @purchases.collect{|p| p.total}.sum
    @profit = @purchases.collect{|p| p.profit}.sum
  end
  
  def data
    @days = params[:days].to_i
    @data = []
    
    if @days == 1
      @start_date = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 4, 0)
    elsif @days == 7
      @start_date = DateTime.parse(Date.commercial(Date.today.year, Date.today.cweek, 1).strftime("%m/%d/%Y") + " 04:00:00")
    end
    
    for i in 0..(@days - 1)
      @registrations = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
      @referrals = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days]).delete_if{|u| Credit.find(:all, :conditions => ['user_id = ? and referrer_user_id > 0', u.id]).size == 0}
      @subscriptions = User.find(:all, :conditions => ['created_at >= ? and created_at < ? and gets_daily_deal_email = ?', @start_date + i.days, @start_date + (i + 1).days, true])
      @purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
      @first_purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ['user_id = ?', p.user_id], :order => 'created_at ASC').id}
      @deals = Coupon.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
      @revenue = @purchases.collect{|p| p.deals_total}.sum
      @revenue_post_credit = @purchases.collect{|p| p.total}.sum
      @profit = @purchases.collect{|p| p.profit}.sum
      
      @data[i] = [(@start_date + i.days).strftime("%m/%d/%Y"), @registrations.size, @referrals.size, @subscriptions.size, @purchases.size, @first_purchases.size, @deals.size, @purchases.collect{|p| p.early_bird_losses}.sum, @revenue, @revenue_post_credit, @profit - (@revenue - @revenue_post_credit), @deals.empty? ? 0 : @revenue / @deals.size, @revenue > 0 ? @profit / @revenue : 0]
    end
    
    respond_to do |format|
      format.csv
    end
  end
  
  def affiliates
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @start_date = params[:start_date].nil? ? Date.new(@now.year, @now.month, 1) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? Date.new(@now.year, @now.month, -1) : DateTime.parse(params[:end_date] + " 04:00:00")

    @businesses = Business.find(Origin.find(:all, :conditions => ['business_id != ?', 25]).collect{|o| o.business_id}.uniq, :order => 'name asc')
  end
  
  def affiliate_lifetime
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @start_date = params[:start_date].nil? ? Date.new(@now.year, @now.month, 1) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? Date.new(@now.year, @now.month, -1) : DateTime.parse(params[:end_date] + " 04:00:00")

    @businesses = Business.find(Origin.find(:all, :conditions => ['business_id != ?', 25]).collect{|o| o.business_id}.uniq, :order => 'name asc')
  end
  
  def promotions
    if !params[:business_id].blank?
      @promotions = Business.find(params[:business_id]).promotions
    elsif !params[:id].blank?
      @promotions = [Promotion.find(params[:id])]
    elsif params[:all]
      @promotions = Promotion.all
    else
      @promotions = Promotion.find(:all, :conditions => ['start_date <= ?', Date.today + 1.day], :limit => 3, :order => 'start_date DESC')
    end
  end
  
  def washingtonian
    @show_breakdowns = (params[:show_breakdowns].blank? or params[:show_breakdowns] == "false") ? false : true
    @start_date = params[:start_date].nil? ? DateTime.new(Time.zone.now.year, Time.zone.now.month, 1) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(Time.zone.now.year, Time.zone.now.month, -1) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    if !params[:business_id].blank?
      @promotions = Business.find(params[:business_id]).promotions
    elsif !params[:id].blank?
      @promotions = [Promotion.find(params[:id])]
    elsif params[:all]
      @promotions = Promotion.all
    elsif params[:start_date].blank?
      @promotions = Promotion.find(:all, :conditions => ['end_date >= ? and end_date < ?', @start_date, @end_date + 1.day], :order => 'end_date asc')
    else
      @promotions = Promotion.find(:all, :conditions => ['end_date >= ? and end_date < ?', @start_date, @end_date + 1.day], :order => 'end_date asc')
    end
  end
  
  def source_report
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    @start_date = params[:start_date].nil? ? Date.new(@now.year, @now.month, 1) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? Date.new(@now.year, @now.month, -1) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    if !params[:business_id].blank?
      params[:source] = ""
      params[:medium] = ""
      params[:campaign] = ""
    else
      params[:business_id] = ""
    end

    @businesses = Business.find(Origin.find(:all, :conditions => ['origin_type != ?', 4]).collect{|o| o.business_id}.uniq, :order => 'name asc')
    @sources = Origin.find(:all, :conditions => ["source is not null #{'and medium = \'' + params[:medium] + '\'' unless params[:medium].blank?} #{'and campaign = \'' + params[:campaign] + '\'' unless params[:campaign].blank?} "], :group => 'source', :order => 'source ASC')
    @mediums = Origin.find(:all, :conditions => ["medium is not null #{'and source = \'' + params[:source] + '\'' unless params[:source].blank?} #{'and campaign = \'' + params[:campaign] + '\'' unless params[:campaign].blank?} "], :group => 'medium', :order => 'medium ASC')
    @campaigns = Origin.find(:all, :conditions => ["campaign is not null #{'and source = \'' + params[:source] + '\'' unless params[:source].blank?} #{'and medium = \'' + params[:medium] + '\'' unless params[:medium].blank?} "], :group => 'campaign', :order => 'campaign ASC')
    
    if params[:all] == 'heck_ya'
      @origins = Origin.find(:all, :conditions => ['origin_type != ?', 4])
    elsif !params[:business_id].blank?
      @origins = Origin.find(:all, :conditions => {:business_id => params[:business_id]})
    elsif !params[:source].blank? or !params[:medium].blank? or !params[:campaign].blank?
      @origins = Origin.find(:all, :conditions => ["origin_type != ? #{'and source = \'' + params[:source] + '\'' unless params[:source].blank?}  #{'and medium = \'' + params[:medium] + '\'' unless params[:medium].blank?} #{'and campaign = \'' + params[:campaign] + '\'' unless params[:campaign].blank?} ", 4])
    else
      @origins = []
    end
  end
  
  def earn_out
    @start_date = DateTime.new(2011, 5, 1, 4, 0)
    @end_date   = DateTime.new(@now.year, @now.month, @now.day, 4, 0)

    @partner_id = params[:partner_id].to_i

    @registrations = User.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day])
    # @referrals = User.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s unless @partner_id.nil?}", @start_date, @end_date + 1.day]).delete_if{|u| Credit.find(:all, :conditions => ["user_id = ? and referrer_user_id > 0", u.id]).size == 0}
    @subscriptions = User.find(:all, :conditions => ["created_at >= ? and created_at < ? and gets_daily_deal_email = ? #{"and partner_id = " + @partner_id.to_s unless @partner_id.nil?}", @start_date, @end_date + 1.day, true])
    @purchases = Purchase.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s if @partner_id > 0}", @start_date, @end_date + 1.day])
    # @first_purchases = Purchase.find(:all, :conditions => ["created_at >= ? and created_at < ? #{"and partner_id = " + @partner_id.to_s unless @partner_id.nil?}", @start_date, @end_date + 1.day]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ["user_id = ?", p.user_id], :order => "created_at ASC").id}
    @vouchers = @purchases.collect{|p| p.coupons}.flatten
    @revenue_post_credit = @purchases.collect{|p| p.total}.sum
    @net_revenue = @purchases.collect{|p| p.net_revenue}.sum 
  end
end