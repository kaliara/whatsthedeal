# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user, :cart, :partner, :originize, :mobile, :force_full_site, :https?, :simple_page?
  filter_parameter_logging :password, :number
  before_filter :store_return_uri, :set_timezone
  before_filter :admin_required, :only => ['impersonate']
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  def set_timezone
    # eventually this should be set by metro
    Time.zone = 'Eastern Time (US & Canada)'
  end
  
  def https?
    request.protocol.include? "https"
  end

  def mobile
    return !session[:force_full_site] unless session[:force_full_site].blank?
    request.user_agent.blank? ? false : (request.user_agent.downcase.include?('mobile') or request.user_agent.downcase.include?('android')) and !request.user_agent.downcase.include?('ipad')
  end
  
  def force_full_site
    session[:force_full_site] = true
  end
  
  def simple_page?(controller)
    controller.action_name == 'signup'
  end
  
  # partner subdomain check
  def partner
    return @partner if defined?(@partner)
    
    if !request.subdomains.empty? and (request.subdomains.first == 'washingtonian')
      @partner = 0
    elsif !request.subdomains.empty? and (request.subdomains.first == 'halfpricedc')
      @partner = 3
    else
      @partner = 0
    end
    @partner
  end
  
  def hyrbrid_layout_application
    if mobile
      'mobile'
    else
      ['application','sloopy','washingtonian','halfpricedc'][partner]
    end
  end
  
  def hyrbrid_layout_nosidebar
    if mobile
      'mobile'
    else
      ['no_sidebar','sloopy','washingtonian','halfpricedc'][partner]
    end
  end
  
  # process affiliates
  def originize(param)
    CGI.unescape(param.to_s).downcase.gsub(/\W+/,"")
  end
  
  def check_origin
    cookies[:origin] = cookies[:ptc] unless cookies[:ptc].nil?
    return cookies[:origin] if !cookies[:origin].nil?

    params[:utm_source]   ||= 'x'
    params[:utm_medium]   ||= 'x'
    params[:utm_campaign] ||= 'x'
    
    if !params[:sub_id].blank?
      unless Origin.exists?(:sub_id => params[:sub_id], :business_id => Origin::CPAS[params[:code].to_s])
        @origin = Origin.new
        @origin.name = params[:code].to_s + " (sub_id:" + params[:sub_id].to_s + ")"
        @origin.sub_id = params[:sub_id]
        @origin.origin_type = 5
        @origin.business_id = Origin::CPAS[params[:code].to_sym]
        @origin.code = params[:code].to_s + "_" + params[:sub_id].to_s
        @origin.save
      else
        @origin = Origin.find(:first, :conditions => {:sub_id => params[:sub_id], :business_id => Origin::CPAS[params[:code].to_s]})
      end
      cookies[:origin] = {:value => @origin.code, :expires => 6.months.from_now}
    elsif params[:utm_source] != 'x' or params[:utm_medium] != 'x' or params[:utm_campaign] != 'x'
      unless Origin.exists?(:source => originize(params[:utm_source]), :medium => originize(params[:utm_medium]), :campaign => originize(params[:utm_campaign]))
        @origin = Origin.new
        @origin.name = "#{originize(params[:utm_campaign])} #{originize(params[:utm_source])} #{originize(params[:utm_medium])}"
        @origin.origin_type = 5
        @origin.business_id = 25
        @origin.source = originize(params[:utm_source])
        @origin.medium = originize(params[:utm_medium])
        @origin.campaign = originize(params[:utm_campaign])
        @origin.code = "#{originize(params[:utm_campaign])}_#{originize(params[:utm_source])}_#{originize(params[:utm_medium])}"
        @origin.save
      else
        @origin = Origin.find(:first, :conditions => {:source => originize(params[:utm_source]), :medium => originize(params[:utm_medium]), :campaign => originize(params[:utm_campaign])})
      end
      cookies[:origin] = {:value => @origin.code, :expires => 6.months.from_now}
    else
      if (params[:ptc] and !Origin.find_by_code(params[:code]).nil?)
        cookies[:origin] = {:value => params[:code], :expires => 6.month.from_now}
        flash[:notice] = "Thanks for visiting WTD from #{Origin.find_by_code(params[:code]).business.name}!" unless Origin.find_by_code(params[:code]).embedded?
      end
    end
  end

  private
    def cart
      #return @cart if defined?(@cart)
      
      if current_user
        if session[:cart_id]
          @cart = Cart.exists?(session[:cart_id]) ? Cart.find(session[:cart_id]) : Cart.create
        elsif current_user.cart
          @cart = current_user.cart
        else
          @cart = Cart.create
        end
        @cart.user_id = current_user.id
        @cart.save
      else
        if session[:cart_id]
          @cart = Cart.exists?(session[:cart_id]) ? Cart.find(session[:cart_id]) : Cart.create
        else
          @cart = Cart.create
        end
      end
      
      session[:cart_id] = @cart.id
      @cart
    end
  
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    
    # redirect somewhere that will eventually return back to here
    def redirect_away(*params)
      session[:return_to] = request.request_uri.nil? ? root_path : request.request_uri
      redirect_to(*params)
    end
    
    # returns the person to either the original url from a redirect_away or to a default url
    def redirect_back(*params)
      uri = session[:return_to].nil? ? root_path : session[:return_to]
      session[:return_to] = nil
      if uri
        redirect_to uri
      else
        redirect_to(*params)
      end
    end
    
    # looks for a return_uri in params
    def store_return_uri
      if params[:return_uri]        
        session[:return_to] = params[:return_uri]
      end
    end
    
    # check and set impersonation for a customer
    def impersonate_customer
      if current_user and current_user.admin? and current_user.admin.customer_impersonation_id.to_i > 0
        @current_user = Customer.find(current_user.admin.customer_impersonation_id).user
      end
    end

    # check and set impersonation for a business
    def impersonate_business
      if current_user and current_user.admin? and current_user.admin.business_impersonation_id.to_i > 0
        @current_user = Business.find(current_user.admin.business_impersonation_id).user
      end
    end
  
  
  protected
    def staff_required
      flash[:error] = "Sorry, but you dont' have access to do this. E-mail matt@sowhatsthedeal.com with questions."
      redirect_away(:controller => '/admin/home', :action => 'login') unless (current_user and current_user.staff?)
    end
    def admin_required
      redirect_away(:controller => '/admin/home', :action => 'login') unless (current_user and current_user.admin?)
    end
    def business_required
      redirect_away(:controller => '/business/home', :action => 'login') unless (current_user and current_user.business?)
    end
    def business_staff_required
      redirect_away(:controller => '/business/home', :action => 'login') unless (current_user and current_user.business_staff?)
    end
    def customer_required
      redirect_away(:controller => '/user_sessions', :action => 'new') unless (current_user and current_user.customer)
    end
end