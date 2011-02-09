class EventsController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application

  def index
    @promotions = [Promotion.find(289)]
    @events = Event.find(:all, :conditions => ['rotation_start_date <= ? and rotation_end_date >= ?', Date.today, Date.today], :order => 'created_at DESC')
    
    session[:stored_promotion_code_id] = nil

    if @events.empty? and @promotions.empty?
      flash[:error] = "Sorry, there are no events going on right now. <a href='/signup'>Signup for our listserv</a> to make sure you don't miss the next one!"
      redirect_to root_path
    else
      @side_promotions = Promotion.sidebar
      render :action => 'index'
    end
  end
  
  def show
    @event = Event.find(params[:id])
    @side_promotions = Promotion.sidebar
    @user_session = UserSession.new
    @user = User.new
    @user.customer = Customer.new
    
    session[:stored_promotion_code_id] = nil
    
    if @event.in_rotation? or params[:password] == Event::PREVIEW_PASSWORD
      render :action => 'show'
    else
      flash[:error] = "Sorry, but that event is not available right now. Email us at support@sowhatsthedeal.com if you need help."
      redirect_to root_path
    end
  end
  
end    