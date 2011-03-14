class Admin::DashboardsController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  def index
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @start_date = params[:start_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    # some of these can be converted into count_by_sql
    @registrations = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day])
    @referrals = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day]).delete_if{|u| Credit.find(:all, :conditions => ['user_id = ? and referrer_user_id > 0', u.id]).size == 0}
    @subscriptions = User.find(:all, :conditions => ['created_at >= ? and created_at < ? and gets_daily_deal_email = ?', @start_date, @end_date + 1.day, true])
    @purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day])
    @first_purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ['user_id = ?', p.user_id], :order => 'created_at ASC').id}
    @deals = Coupon.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day])
  end
  
  def partners
    @partner = 2
    
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @start_date = params[:start_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(@now.year, @now.month, @now.day, 4, 0) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    # some of these can be converted into count_by_sql
    @registrations = User.find(:all, :conditions => ['partner_id = ? and created_at >= ? and created_at < ?', @partner, @start_date, @end_date + 1.day])
    @referrals = User.find(:all, :conditions => ['partner_id = ? and created_at >= ? and created_at < ?', @partner, @start_date, @end_date + 1.day]).delete_if{|u| Credit.find(:all, :conditions => ['user_id = ? and referrer_user_id > 0', u.id]).size == 0}
    @subscriptions = User.find(:all, :conditions => ['partner_id = ? and created_at >= ? and created_at < ? and gets_daily_deal_email = ?', @partner, @start_date, @end_date + 1.day, true])
    @purchases = Purchase.find(:all, :conditions => ['partner_id = ? and created_at >= ? and created_at < ?', @partner, @start_date, @end_date + 1.day])
    @first_purchases = Purchase.find(:all, :conditions => ['partner_id = ? and created_at >= ? and created_at < ?', @partner, @start_date, @end_date + 1.day]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ['user_id = ?', p.user_id], :order => 'created_at ASC').id}
    @deals = Coupon.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day]).delete_if{|c| c.purchase.partner_id != @partner}
    
    render :action => 'index'
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
end