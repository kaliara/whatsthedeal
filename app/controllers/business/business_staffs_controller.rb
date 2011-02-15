class Business::BusinessStaffsController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_required 
    
  # GET /business_staffs
  # GET /business_staffs.xml
  def index
    @business_staffs = BusinessStaff.find(:all, :conditions => {:business_id => current_user.business.id}, :order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @business_staffs }
    end
  end

  # GET /business_staffs/1
  # GET /business_staffs/1.xml
  def show
    @business_staff = BusinessStaff.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show", :layout => 'no_sidebar'}
      format.xml  { render :xml => @business_staff }
    end
  end

  # GET /business_staffs/new
  # GET /business_staffs/new.xml
  def new
    @business_staff = BusinessStaff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @business_staff }
    end
  end

  # GET /business_staffs/1/edit
  def edit
    @business_staff = BusinessStaff.find(params[:id])
  end

  # POST /business_staffs
  # POST /business_staffs.xml
  def create
    @user = User.new
    @user.email = params[:email]
    @user.password = params[:password]
    @user.password_confirmation = params[:password]
    @user.save
    
    @business_staff = BusinessStaff.new
    @business_staff.user_id = @user.id
    @business_staff.name = params[:name]
    @business_staff.business_id = current_user.business.id

    respond_to do |format|
      if @business_staff.save
        flash[:notice] = 'Staff member was successfully created.'
        format.html { redirect_to(business_business_staffs_path) }
        format.xml  { render :xml => @business_staff, :status => :created, :location => @business_staff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @business_staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /business_staffs/1.xml
  def update
    @business_staff = BusinessStaff.find(params[:id])

    respond_to do |format|
      if @business_staff.update_attributes(params[:business_staff])
        flash[:notice] = 'Staff member was successfully updated.'
        format.html { redirect_to(business_business_staffs_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @business_staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /business_staffs/1
  # DELETE /business_staffs/1.xml
  def destroy
    @business_staff = BusinessStaff.find(params[:id])
    @business_staff.destroy

    respond_to do |format|
      format.html { redirect_to(business_business_staffs_path) }
      format.xml  { head :ok }
    end
  end
end