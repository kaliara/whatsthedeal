class Admin::OriginsController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']

  # GET /origins
  # GET /origins.xml
  def index
    @origins = Origin.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @origins }
    end
  end

  # GET /origins/1
  # GET /origins/1.xml
  def show
    @origin = Origin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @origin }
    end
  end

  # GET /origins/new
  # GET /origins/new.xml
  def new
    @origin = Origin.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @origin }
    end
  end

  # GET /origins/1/edit
  def edit
    @origin = Origin.find(params[:id])
  end

  # POST /origins
  # POST /origins.xml
  def create
    @origin = Origin.new(params[:origin])

    respond_to do |format|
      if @origin.save
        flash[:notice] = 'Origin was successfully created.'
        format.html { redirect_to admin_origin_path(@origin) }
        format.xml  { render :xml => @origin, :status => :created, :location => @origin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @origin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /origins/1
  # PUT /origins/1.xml
  def update
    @origin = Origin.find(params[:id])

    respond_to do |format|
      if @origin.update_attributes(params[:origin])
        flash[:notice] = 'Origin was successfully updated.'
        format.html { redirect_to admin_origin_path(@origin) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @origin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def associate_business
    @origin = Origin.find(params[:origin_id])
    @origin.update_attributes(params[:origin])
    
    render :text => @origin.id
  end

  # DELETE /origins/1
  # DELETE /origins/1.xml
  def destroy
    @origin = Origin.find(params[:id])
    @origin.destroy

    respond_to do |format|
      format.html { redirect_to(admin_origins_path) }
      format.xml  { head :ok }
    end
  end
end
