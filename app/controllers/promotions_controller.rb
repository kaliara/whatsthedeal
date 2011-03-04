class PromotionsController < ApplicationController
  before_filter :impersonate_customer, :check_origin
  layout :hyrbrid_layout_application, :except => [:rss, :map]
    
  def home
    @on_home_page = true
    session[:force_full_site] = false
    
    case partner
    when 2
      @promotion = Promotion.washingtonian_featured.empty? ? Promotion.first : Promotion.washingtonian_featured.first
    when 3
      @promotion = Promotion.halfpricedc_featured.empty? ? Promotion.first : Promotion.halfpricedc_featured.first
    else
      @promotion = Promotion.featured.empty? ? Promotion.first : Promotion.featured.first
    end
  
    @side_promotions = Promotion.sidebar(@promotion.id)
    @cart_item = CartItem.new
    
    render :action => mobile ? 'show_m' : 'show'
  end
  
  
  # GET /promotions
  # GET /promotions.xml
  def index
    session[:force_full_site] = false
    
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ?', Time.now.utc, Time.now.utc, true, false], :order  => 'featured DESC, start_date DESC')

    if @promotions.empty?
      redirect_to root_path
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @promotions }
      end
    end
  end

  def map
    @mapped_promotions   = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, true], :order  => 'featured DESC, start_date DESC')
    @unmapped_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, false], :order  => 'featured DESC, start_date DESC')

    @street  = params[:street]
    @city    = params[:city]
    @state   = params[:state]
    @zipcode = params[:zipcode]
    
    if !cookies[:location_latitude].blank? and !cookies[:location_longitude].blank?
      session[:location_latitude]  = cookies[:location_latitude] 
      session[:location_longitude] = cookies[:location_longitude]
    elsif current_user and !current_user.customer.latitude.blank? and !current_user.customer.longitude.blank?
      session[:location_latitude]  = current_user.customer.latitude
      session[:location_longitude] = current_user.customer.longitude
    end

    if @mapped_promotions.empty?
      redirect_to promotions_path
    else
      render :action => "map", :layout => hyrbrid_layout_nosidebar
    end
  end

  # GET /promotions/1
  # GET /promotions/1.xml
  def show
    session[:force_full_site] = false
    session[:clicked_promotion_map] = params[:clicked_promotion_map]
    
    case partner
    when 2
      @promotion = params[:featured] ? Promotion.washingtonian_featured.first : Promotion.find_by_slug(params[:slug])
    when 3
      @promotion = params[:featured] ? Promotion.halfpricedc_featured.first : Promotion.find_by_slug(params[:slug])
    else
      @promotion = params[:featured] ? Promotion.featured.first : Promotion.find_by_slug(params[:slug])
    end
    if @promotion.nil?
      flash[:error] = "We have updated some of the links to our promotions, please select a promotion from the list below"
      redirect_to promotions_path
    else
      flash.now[:error] = "Did you miss this deal? <a href='/signup'>Signup for the our Daily Deal e-mails</a> never miss out again!" unless @promotion.end_date > Time.now.utc
      
      @side_promotions = Promotion.sidebar(@promotion.id)
      @cart_item = CartItem.new
    
      # track action
      session[:viewed_promotion] = true
      session[:clicked_other_promotion] = params[:clicked_other_promotion]

      respond_to do |format|
        format.html { render :action => mobile ? 'show_m' : 'show' }
        format.xml  { render :xml => @promotions }
      end
    end
  end
  
  def buy_credit
    @promotion = Promotion.find(266)
    @side_promotions = Promotion.sidebar(@promotion.id)
    @cart_item = CartItem.new
  end
  
  def ad_preview
    @promotion = Promotion.find(:first, :order => "updated_at DESC")
    render :action => 'show'
  end
  
  def rss
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and active = ? and hidden = ?', Time.now.utc, true, false], :order => 'start_date DESC', :limit => 5)
  end

  def lon
    @featured_promotion = Promotion.featured.first
    @other_promotions = Promotion.find(:all, :conditions => ['start_date < ? and active = ? and hidden = ? and id != ?', Time.now.utc, true, false, @featured_promotion.id], :order => 'start_date DESC', :limit => 10)
  end
end