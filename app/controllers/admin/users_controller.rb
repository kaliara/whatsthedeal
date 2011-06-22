class Admin::UsersController < ApplicationController
  layout 'admin'
  before_filter :admin_required
  
  # GET /users
  # GET /users.xml
  def index
    if params[:q] =~ /\@/
      @type = "Email"
      @users = User.find_by_email(params[:q]).to_a
    elsif params[:q] =~ /\d+/
      @type = "ID"
      @users = User.exists?(params[:q]) ? User.find(params[:q]).to_a : []
    else
      @users = User.find(:all, :order => 'created_at DESC', :limit => 20)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    # @user = User.new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to (admin_users_path) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to (admin_users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
  
  def credit_profile
    @user = params[:email].blank? ? User.last : User.find_by_email(params[:email])
    @credits = @user.credits unless @user.nil?
    @referral_credits = Credit.find(:all, :conditions => {:referrer_user_id => @user.id}).delete_if{|c| c.purchase_id.nil?} unless @user.nil?
  end
end