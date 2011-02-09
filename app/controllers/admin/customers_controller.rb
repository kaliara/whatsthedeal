class Admin::CustomersController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /customers
  # GET /customers.xml
  def index
   if params[:q] =~ /\@/
      @type = "Email"
      @user = User.find_by_email(params[:q])
      @customers = @user.nil? ? [] : Customer.find(:all, :conditions => {:user_id => @user.id}, :order => 'created_at DESC')
    elsif params[:q] =~ /\w+/
      @type = "a First or Last Name Like"
      @customers = Customer.find(:all, :conditions => ['first_name like ? or last_name like ?', "#{params[:q]}%", "#{params[:q]}%"]).to_a
    else
      @customers = Customer.find(:all, :order => 'created_at DESC', :limit => 20)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])
    @user = @customer.user
    @active_coupons = @customer.user.coupons.active
    @inactive_coupons = @customer.user.coupons.inactive
    @printed_coupons = @customer.user.coupons.printed
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @user = User.new
    @user.customer = Customer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @user = Customer.find(params[:id]).user
    # @user.customer = Customer.new
        
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @user = Customer.find(params[:id]).user

    respond_to do |format|
     if @user.update_attributes(params[:user])
       flash[:notice] = 'User was successfully updated.'
       format.html { redirect_to(admin_customers_path) }
       format.xml  { head :ok }
     else
       format.html { render :action => "edit" }
       format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
     end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    flash[:notice] = "Customer removed. Goodbye!"
    
    respond_to do |format|
      format.html { redirect_to(admin_customers_path) }
      format.xml  { head :ok }
    end
  end
end