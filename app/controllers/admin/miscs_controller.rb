class Admin::MiscsController < ApplicationController
  before_filter :admin_required
  layout 'admin'
  
  # GET /miscs
  # GET /miscs.xml
  def index
    @miscs = Misc.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @miscs }
    end
  end

  # GET /miscs/new
  # GET /miscs/new.xml
  def new
    @misc = Misc.new
    @misc.misc = params[:misc] unless params[:misc].blank?
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @misc }
    end
  end

  # GET /miscs/1/edit
  def edit
    @misc = Misc.find(params[:id])
  end

  # POST /miscs
  # POST /miscs.xml
  def create
    @misc = Misc.new(params[:Misc])

    respond_to do |format|
      if @misc.save
        flash[:notice] = 'Misc was successfully created.'
        format.html { redirect_to :action => 'index' }
        format.xml  { render :xml => @misc, :status => :created, :location => @Misc }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @misc.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /miscs/1
  # PUT /miscs/1.xml
  def update
    @misc = Misc.find(params[:id])

    respond_to do |format|
      if @misc.update_attributes(params[:misc])
        flash[:notice] = 'Misc was successfully updated.'
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @misc.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /miscs/1
  # DELETE /miscs/1.xml
  def destroy
    @misc = Misc.find(params[:id])
    @misc.destroy

    respond_to do |format|
      format.html { redirect_to(admin_miscs_path) }
      format.xml  { head :ok }
    end
  end
end
