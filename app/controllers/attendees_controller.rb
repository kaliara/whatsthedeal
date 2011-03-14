class AttendeesController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_nosidebar
  
  def index
    redirect_to params[:event_id].blank? ? events_path : event_path(params[:event_id])
  end
  
  def create
    @event = Event.find(params[:event_id])
    
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
      
      @user.gets_happy_hour_announcement_email = params[:gets_happy_hour_announcement_email] unless params[:gets_happy_hour_announcement_email].blank?
      @user.gets_daily_deal_email = params[:gets_daily_deal_email] unless params[:gets_daily_deal_email].blank?
      
      @attendee = Attendee.new({:user_id => @user.id, :event_id => @event.id})
      @attendee.survey_question_value = session[:survey_question_value].blank? ? params[:survey_question_value] : session[:survey_question_value]
      session[:survey_question_value] = nil
      @attendee.save
    
      if @user.update_subscriptions(request.referrer, @event.subscription_list_id, true) and !params[:gets_daily_deal_email].blank?
        session[:new_subscriber] = true
        session[:new_subscriber_email] = @user.email
      end
      
      @user.save

      session[:return_to] ? redirect_to(session[:return_to]) : render(:action => 'show')
    else
      flash[:error] = "We need your first and last name and a valid email to RSVP you for this event. <strong>Also, if you already have an account, you can login instead</strong>."
      redirect_to @event
    end
  end

end