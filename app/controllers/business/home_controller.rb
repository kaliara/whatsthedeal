class Business::HomeController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_required, :except => [:login]

  def index
    @businesses = Business.find(:all, :conditions => {:user_id => current_user.id})
    @affiliate_start_date = params[:affiliate_start_date].nil? ? Date.commercial(Date.today.year, Date.today.cweek, 1) : DateTime.parse(params[:affiliate_start_date] + " 04:00:00")
    @affiliate_end_date = params[:affiliate_end_date].nil? ? Date.commercial(Date.today.year, Date.today.cweek, 7) : DateTime.parse(params[:affiliate_end_date] + " 04:00:00")
  end
  
  def login
    @user_session = UserSession.new
    @user = User.new
  end

end