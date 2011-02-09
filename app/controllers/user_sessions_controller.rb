class UserSessionsController < ApplicationController
  layout :hyrbrid_layout_nosidebar
  
  before_filter :check_origin
  
  def new
    session[:force_full_site] = false
    session[:return_to] = params[:return_to] unless params[:return_to].blank?
    
    @user_session = UserSession.new
    @user = User.new
    @user.customer = Customer.new
    
    render :action => mobile ? 'new_m' : 'new'
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      unless session[:cart_id].nil? or (!current_user.cart.nil? and (session[:cart_id] == current_user.cart.id))
        # destroy old cart
        Cart.find_by_user_id(current_user.id).destroy if Cart.find_by_user_id(current_user.id)

        # grab new cart from session
        cart = Cart.find(session[:cart_id])
        cart.user_id = current_user.id
        cart.save  
      end
      
      if current_user.staff?
        redirect_to admin_home_path
      elsif current_user.business?
        redirect_to business_home_path
      else
        # try to get back to where user came from
        redirect_to session[:return_to] ? session[:return_to] : my_deals_path
      end
    else
      flash[:error] = "There was a problem with your login information. Please try again.<br/><br/><br/><strong>Forgot your password? You can <a href='/forgot_password'>reset your password here</a></strong>."
      @user_session.errors.clear
      redirect_to session[:return_to] ? session[:return_to] : login_path
    end
  end

  def destroy
    session[:cart_id] = nil
    session[:return_to] = nil
    session[:newsletter_subscriber] = nil
    session[:stored_promotion_code_id] = nil
    session[:floating_email] = nil
    session[:new_subscriber_email] = nil
    current_user_session.destroy if current_user_session
    redirect_to new_user_session_url
  end
end
