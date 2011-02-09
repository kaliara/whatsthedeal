class Admin::BusinessesController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /businesses
  # GET /businesses.xml
  def index
    @businesses = Business.find(:all, :order => "name ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @businesses }
    end
  end

  # GET /businesses/new
  # GET /businesses/new.xml
  def new
    @user = User.new
    @user.business = Business.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /businesses/1/edit
  def edit
    @business = Business.find(params[:id])
    # @business = current_user.business
  end

  # POST /businesses
  # POST /businesses.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Business was successfully created.'
        format.html { redirect_to (admin_businesses_path) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /businesses/1
  # PUT /businesses/1.xml
  def update
    @business = Business.find(params[:id])
    # @business = current_user.business

    respond_to do |format|
      if @business.update_attributes(params[:business])
        flash[:notice] = 'Business was successfully updated.'
        format.html { redirect_to (admin_businesses_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @business.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.xml
  def destroy
    @business = Business.find(params[:id])
    @business.destroy

    respond_to do |format|
      format.html { redirect_to(admin_businesses_path) }
      format.xml  { head :ok }
    end
  end
end
