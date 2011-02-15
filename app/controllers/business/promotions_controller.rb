class Business::PromotionsController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_required 
    
  # GET /promotions
  # GET /promotions.xml
  def index
    @business_ids = Business.find(:all, :conditions => {:user_id => current_user.id}).collect{|b| b.id}
    @promotions = Promotion.find(:all, :conditions => {:business_id => @business_ids}, :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @promotions }
    end
  end

  # GET /promotions/1
  # GET /promotions/1.xml
  def show
    @promotion = Promotion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @promotions }
    end
  end

  # GET /promotions/new
  # GET /promotions/new.xml
  def new
    @promotion = Promotion.new
      
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @promotion }
    end
  end

  # GET /promotions/1/edit
  def edit
    @promotion = Promotion.find(params[:id])
  end

end
