class EntriesController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_nosidebar
  
  def index
    session[:return_to] = nil
    redirect_to params[:raffle_id].blank? ? raffles_path : raffle_path(params[:raffle_id])
  end
  
  def create
    @raffle = Raffle.find(params[:id])
    
    # update name if necessary
    if params[:first_name] and params[:last_name]
      @user = current_user
      @user.customer.first_name = params[:first_name]
      @user.customer.last_name = params[:last_name]
      @user.save
    end
    
    if current_user and current_user.customer.has_name?
      @user = current_user
      @side_promotions = Promotion.sidebar
      
      @entry = Entry.new({:user_id => @user.id, :raffle_id => @raffle.id})
      @entry.save
    
      @user.gets_happy_hour_announcement_email = params[:gets_happy_hour_announcement_email] unless params[:gets_happy_hour_announcement_email].blank?
      @user.gets_daily_deal_email = params[:gets_daily_deal_email] unless params[:gets_daily_deal_email].blank?
      
      if @user.update_subscriptions(request.referrer, @raffle.subscription_list_id, true) and !params[:gets_daily_deal_email].blank?
        session[:new_subscriber] = true
        session[:new_subscriber_email] = @user.email
      end
      
      @user.save

      session[:return_to] ? redirect_to(session[:return_to]) : render(:action => 'show')
    else
      flash[:error] = "We need your first and last name and a valid email to enter you into the raffle.  Also, <strong>already have an account, you can login on the left</strong>"
      redirect_to @raffle
    end
  end

end