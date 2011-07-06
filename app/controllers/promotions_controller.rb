class PromotionsController < ApplicationController
  before_filter :impersonate_customer, :check_origin
  layout :hyrbrid_layout_application, :except => [:rss, :map]
    
  def home
    @on_home_page = true
    @backup_promotion = Promotion.featured.empty? ? Promotion.first : Promotion.featured.first
    session[:force_full_site] = false
    
    case partner
    when 2
      @promotion = Promotion.washingtonian_featured.empty? ? @backup_promotion : Promotion.washingtonian_featured.first
    when 3
      @promotion = Promotion.halfpricedc_featured.empty? ? @backup_promotion : Promotion.halfpricedc_featured.first
    else
      if region == 1
        @promotion = Promotion.dc_featured.empty? ? @backup_promotion : Promotion.dc_featured.first
        @alt_featured_promotion = Promotion.nova_featured.first
        @side_promotions = Promotion.sidebar([@promotion.id, Promotion.nova_featured], region)
      elsif region == 2
        @promotion = Promotion.nova_featured.empty? ? @backup_promotion : Promotion.nova_featured.first
        @alt_featured_promotion = Promotion.dc_featured.first
        @side_promotions = Promotion.sidebar([@promotion.id, Promotion.dc_featured], region)
      else
        @promotion = @backup_promotion
        @alt_featured_promotion = Promotion.featured.first
        @side_promotions = Promotion.sidebar([@promotion.id], region)
      end
    end
  
    @cart_item = CartItem.new
    
    render :action => mobile ? 'show_m' : 'show'
  end
  
  
  # GET /promotions
  # GET /promotions.xml
  def index
    session[:force_full_site] = false
    @no_alt_featured_promotion = true
    
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ?', Time.now.utc, Time.now.utc, true, false], :order  => 'start_date DESC')

    if @promotions.empty?
      redirect_to root_path
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @promotions }
      end
    end
  end

  # GET /promotions/grab_bag
  def grab_bag
    session[:force_full_site] = true
    
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and grab_bag = ?', Time.now.utc, Time.now.utc, true, true], :order  => 'dc_featured DESC, start_date DESC')
    @side_promotions = Promotion.sidebar([@promotions.first.id], region)

    if @promotions.empty?
      redirect_to promotions_path
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @promotions }
      end
    end
  end

  def map
    @mapped_promotions   = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, true], :order  => 'dc_featured DESC, start_date DESC')
    @unmapped_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and physical_address = ?', Time.now.utc, Time.now.utc, true, false, false], :order  => 'dc_featured DESC, start_date DESC')

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
    
    if params[:arlnow]
      @promotion = Promotion.arlnow
    else
      case partner
      when 2
        @promotion = params[:dc_featured] ? Promotion.washingtonian_featured.first : Promotion.find_by_slug(params[:slug])
      when 3
        @promotion = params[:dc_featured] ? Promotion.halfpricedc_featured.first : Promotion.find_by_slug(params[:slug])
      else
        @promotion = params[:dc_featured] ? Promotion.dc_featured.first : Promotion.find_by_slug(params[:slug])
      end
    end
    
    if @promotion.nil?
      flash[:error] = "We have updated some of the links to our promotions, please select a promotion from the list below"
      redirect_to promotions_path
    else
      flash.now[:error] = "Did you miss this deal? <a href='/signup'>Signup for the our Daily Deal e-mails</a> never miss out again!" unless @promotion.end_date > Time.now.utc
      
      @side_promotions = Promotion.sidebar([@promotion.id], region)
      @alt_featured_promotion = region == 1 ? Promotion.nova_featured.first : Promotion.dc_featured.first
      
      if @alt_featured_promotion.id == @promotion.id
        @back_to_regular = true
        @alt_featured_promotion = region == 1 ? Promotion.dc_featured.first : Promotion.nova_featured.first
      end        

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
    @side_promotions = Promotion.sidebar([@promotion.id], region)
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