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

  # POST /promotions
  # POST /promotions.xml
  def create
    @promotion = Promotion.new(params[:promotion])

    respond_to do |format|
      if @promotion.save
        flash[:notice] = 'Promotion was successfully created.'
        format.html { redirect_to admin_promotions_path }
        format.xml  { render :xml => @promotion, :status => :created, :location => @promotion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @promotion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /promotions/1
  # PUT /promotions/1.xml
  def update
    @promotion = Promotion.find(params[:id])

    respond_to do |format|
      if @promotion.update_attributes(params[:promotion])
        flash[:notice] = 'Promotion was successfully updated.'
        format.html { redirect_to admin_promotions_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @promotion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.xml
  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy

    respond_to do |format|
      format.html { redirect_to admin_promotions_path }
      format.xml  { head :ok }
    end
  end
end
