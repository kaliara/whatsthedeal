class DelayedSubscriptionsController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application
  
  def create
    @ds = DelayedSubscription.new
    @ds.email = params[:email]
    @ds.list = params[:list]
    @ds.referrer = params[:referrer]
    @ds.save
    
    if (@ds.list == User::MARYLAND_DEAL_LIST.to_i or @ds.list == User::VIRGINIA_DEAL_LIST.to_i) and User.exists?(:email => @ds.email)
      @user = User.find_by_email(@ds.email)
      @user.gets_va_daily_deal_email = true if @ds.list == User::VIRGINIA_DEAL_LIST.to_i
      @user.gets_md_daily_deal_email = true if @ds.list == User::MARYLAND_DEAL_LIST.to_i
      @user.save
    end
    
    render :action => 'confirmation'
  end
end