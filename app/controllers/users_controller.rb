class UsersController < ApplicationController
  before_filter :check_origin, :force_full_site
  before_filter :impersonate_customer, :except => [:create]
  before_filter :customer_required, :except => [:new, :create, :referral_signup, :forgot_password, :reset_password, :new_password, :update_password, :newsletter_signup, :quiet_create, :set_location, :clear_location]
  before_filter :load_user_using_perishable_token, :only => [:new_password, :update_password] 
  
  layout :hyrbrid_layout_nosidebar, :except => [:new]
  
  def set_location
    unless params[:latitude].blank? or params[:longitude].blank?
      session[:location_latitude]  = params[:latitude]
      session[:location_longitude] = params[:longitude]
      
      if params[:set_defaul_location].to_i == 1
        cookies[:location_latitude]  = {:value => params[:latitude], :expires => 12.months.from_now}
        cookies[:location_longitude] = {:value => params[:longitude], :expires => 12.months.from_now}

        if current_user
          @user = current_user
          @user.customer.latitude  = params[:latitude]
          @user.customer.longitude = params[:longitude]
          @user.customer.street1   = params[:street]
          @user.customer.city      = params[:city]
          @user.customer.state     = params[:state]
          @user.customer.zipcode   = params[:zipcode]
          @user.save
        end
      end
    else
      flash[:error] = "Sorry, but we couldn't find that location. You can still <a href='/users/set_location?latitude=#{Promotion::PROMOTION_MAP_DEFAULT_LAT}&longitude=#{Promotion::PROMOTION_MAP_DEFAULT_LNG}'>browse the map</a>."
    end
    redirect_to promotion_map_path
  end
  
  def clear_location
    session[:location_latitude]  = nil
    session[:location_longitude] = nil
    cookies[:location_latitude]  = nil
    cookies[:location_longitude] = nil
    if current_user
      current_user.customer.latitude = nil
      current_user.customer.longitude = nil
      current_user.save
    end
    redirect_to promotion_map_path
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    unless current_user
      flash[:error] = "You must be logged in to view your account."
      redirect_away(login_path)    
    else
      @user = current_user
      @tab = params[:tab]
      @on_my_account = true
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @customer }
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @user.customer = Customer.new
    
    @side_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ?', Time.now.utc, Time.now.utc, true, false], :order => 'updated_at DESC', :limit => 4)
    @hide_community_corner = true

    # setup promo code from params
    if !params[:referral_code].blank? and PromotionCode.exists?(:code => params[:referral_code])
      session[:stored_promotion_code_id] = PromotionCode.find_by_code(params[:referral_code]).id
    end

    render :action => 'new', :layout => hyrbrid_layout_application
  end

  # GET /users/1/edit
  def edit
    unless current_user
      flash[:error] = "You must be logged in to edit your account."
      redirect_away(login_path)    
    else
      @user = current_user
          
      respond_to do |format|
        format.html # edit.html.erb
        format.xml  { render :xml => @customer }
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.customer = Customer.new(params[:user][:customer_attributes])
    @user.origin = Origin.find_by_code(cookies[:origin]) if (cookies[:origin] and !Origin.find_by_code(cookies[:origin]).nil?)
    @user.partner_id = partner
    @quietly_create = params[:quietly_create] || false
    
    if User.exists?(:email => @user.email)
      flash[:error] = "<img src='/images/logo.png' align='left' width='99' style='margin: 0pt 10px 10px 0pt; position: relative; top: -12px;'/><strong>This email is already registered with What's the Deal</strong>. <br/><br/>Forgot your password? You can <a href='/forgot_password'>reset your password here</a>."
      redirect_to login_path and return
    end
    
    # setup promo code from params
    if !params[:referral_code].blank? and PromotionCode.exists?(:code => params[:referral_code])
      @promotion_code = PromotionCode.find_by_code(params[:referral_code])
    elsif !session[:stored_promotion_code_id].blank? and PromotionCode.find(session[:stored_promotion_code_id])
      @promotion_code = PromotionCode.find(session[:stored_promotion_code_id])
    else
      @promotion_code = nil
    end

    # quiet create extras
    if @quietly_create
      # @user.email_confirmation = @user.email if @user.email_confirmation.blank?
      @user.password = @user.temporary_password
      @user.password_confirmation = @user.password
      @user.quietly_created = true
      @user.customer.quietly_created = true
    end

    # add survey question if present
    session[:survey_question_value] = params[:survey_question_value] unless params[:survey_question_value].blank?
        
    # update subscriptions and tracking analytics
    if @user.update_subscriptions(request.referrer, nil, true)
      session[:new_subscriber] = true
      session[:new_subscriber_email] = @user.email
    end
        
        
    # check promo code and attempt to save user
    if !@promotion_code.nil? and !@promotion_code.redeemable?
      flash[:error] = 'Sorry, but that promo code is not redeemable!'
      render :action => 'new'
    elsif @user.save      
      flash[:notice] = "<strong>Success! You're officially part of the WTD family.</strong>" unless @quietly_create
      
      # trigger analytics to track
      session[:new_user] = true

      # check referrals and credits
      unless @promotion_code.nil?
        unless @promotion_code.bad_referral?(@user.id)
          @credit = Credit.new
          @credit.promotion_code_id = @promotion_code.id
          @credit.value = @promotion_code.value
          @credit.user_id = @user.id
          @credit.referrer_user_id = @promotion_code.user_id
          @credit.save
        else
          flash[:error] = "Sorry, but there seems to be something wrong with your referral. Please check back in an hour or email us at support@sowhatsthedeal.com."
        end
      end
      
      flash[:notice] = params[:flash_notice] || "Welcome, you are now officially part of the WTD family!"
      flash[:notice] += "<br/><br/><strong>Please <a href='/users/change_password'>choose a password</a> to complete your WTD account.</strong>" if @user.quietly_created?
      flash[:notice] = "Thanks for signing up for Half Price DC" if partner == 3
      redirect_to session[:return_to] ? session[:return_to] : my_account_path(:prompt_alt_list => true)
    else
      @user.password = ""
      @user.password_confirmation = ""
      flash[:error] = "<strong>Be sure to include your first name, last name and a valid email address</strong>. <br/><br/>Remember, If you subscribed to our newsletter, you already have an account. Forgot your password? You can <a href='/forgot_password'>reset your password here</a>." if @user.errors.empty?
      session[:return_to] ? redirect_to(session[:return_to]) : render(:action => 'new')
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user
    @tab = params[:tab]
    @on_my_account = true

    # do in two steps so we can see user.changes
    @user.attributes = params[:user]
    @user.update_subscriptions('http://sowhatsthedeal.com/my_account_email', nil, true)

    if @user.errors.empty? and @user.save
      @user.update_cim_profile
      flash.now[:notice] = "Your #{@tab == 'personal' ? 'account has' : 'email preferences have' } been updated!"
    end
    
    if request.xhr?
      render :text => "success"
    else  
      render :action => @user.errors.on(:password) ? 'change_password' : 'show'
    end
  end
  
  # referral signup stuff
  def referral_signup
    @user = User.new
    @user.customer = Customer.new
    @side_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ?', Time.now.utc, Time.now.utc, true, false], :order => 'updated_at DESC', :limit => 4)
    
    # setup promo code from params
    if !params[:code].blank? and PromotionCode.exists?(:code => params[:code])
      @stored_promotion_code = PromotionCode.find_by_code(params[:code])
      session[:stored_promotion_code_id] = @stored_promotion_code.id
      flash.now[:notice] = "Welcome - you're a friend of #{@stored_promotion_code.user.customer.first_name}, right? Register below to get your $5 credit!<br/>#{@stored_promotion_code.user.customer.first_name} will get his or her credit once you make you first purchase."
    end

    render :action => 'new'
  end

  # change password
  def change_password
    @user = current_user
    @on_my_account = true
    
    render :action => 'change_password'
  end
  
  # forgot password
  def forgot_password
    current_user_session.destroy if current_user_session
    render :action => mobile ? 'forgot_password_m' : 'forgot_password'
  end
  
  def reset_password
    current_user_session.destroy if current_user_session
    @forgetfull_user = User.find_by_email(params[:user][:email])  
    if @forgetfull_user
      @forgetfull_user.password = @forgetfull_user.temporary_password 
      @forgetfull_user.password_confirmation = @forgetfull_user.temporary_password
      if @forgetfull_user.save and @forgetfull_user.deliver_password_reset_instructions!
        cart.empty!
        flash[:notice] = "We've just emailed you a temporary password. Please check your email."  
        redirect_to logout_url  
      else
        flash[:error] = "Sorry, but we had trouble sending the password reset email. Try again in a few minutes, or email us at password@sowhatsthedeal.com and we'll help get things sorted out."  
        redirect_to timeout_error_path  
      end        
    else  
      flash[:notice] = "Sorry, that email address was not found. Try again?"  
      render :action => mobile ? 'forgot_password_m' : 'forgot_password'
    end
  end
  
  def new_password
  end
  
  def update_password
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to my_account_path  
    else  
      render :action => :new_password  
    end
  end
  
  
  private  
  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or <a href='/forgot_password'>click here</a> to reset your password again."  
      redirect_to root_url  
    end
  end
  
  def validate_email(email)
    email =~ /[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  end
end