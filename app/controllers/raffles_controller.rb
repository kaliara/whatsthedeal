class RafflesController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application

  def index
    redirect_to :show
  end
  
  def show
    @raffle = Raffle.find(params[:id])
    @side_promotions = Promotion.sidebar(0, region)
    @user_session = UserSession.new
    @user = User.new
    @user.customer = Customer.new
    
    session[:stored_promotion_code_id] = nil
    
    if @raffle.rotation_start_date <= Date.today or params[:password] == Raffle::PREVIEW_PASSWORD
      flash.now[:error] = "This raffle has ended. Make sure you don't miss another raffle by <a href='/signup'>signing up for our Daily Deal</a>." unless @raffle.in_rotation?
      render :action => 'show'
    else
      flash.now[:error] = "Sorry, but that raffle is not available right now. Email us at support@sowhatsthedeal.com if you need help."
      redirect_to root_path
    end
  end
end    