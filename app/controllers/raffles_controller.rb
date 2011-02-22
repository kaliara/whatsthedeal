class RafflesController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application

  def index
    @raffles = Raffle.find(:all, :conditions => ['rotation_start_date <= ? and rotation_end_date >= ?', Date.today, Date.today], :order => 'created_at DESC')
    
    session[:stored_promotion_code_id] = nil

    if @raffles.empty? and @promotions.empty?
      flash[:error] = "Sorry, there are no raffles going on right now. <a href='/signup'>Signup for our listserv</a> to make sure you don't miss the next one!"
      redirect_to root_path
    else
      @side_promotions = Promotion.sidebar
      render :action => 'index'
    end
  end
  
  def show
    @raffle = Raffle.find(params[:id])
    @side_promotions = Promotion.sidebar
    @user_session = UserSession.new
    @user = User.new
    @user.customer = Customer.new
    
    session[:stored_promotion_code_id] = nil
    
    if @raffle.rotation_start_date <= Date.today or params[:password] == Raffle::PREVIEW_PASSWORD
      flash.now[:error] = "This raffle has ended. Make sure you don't miss another raffle by <a href='/signup'>signing up for our Daily Deal</a>." if Date.today > @raffle.rotation_end_date
      render :action => 'show'
    else
      flash.now[:error] = "Sorry, but that raffle is not available right now. Email us at support@sowhatsthedeal.com if you need help."
      redirect_to root_path
    end
  end
end    