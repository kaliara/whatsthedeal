class Admin::CreditsController < ApplicationController
  layout 'admin'
  before_filter :staff_required 
  
  # GET /credits
  # GET /credits.xml
  def index
    if params[:promotion_code_id]
      @promotion_code = PromotionCode.find(params[:promotion_code_id])
      @credits = @promotion_code.credits
    elsif params[:q] =~ /\@/
      @type = "User OR Referrer Email"
      @credits = Credit.find(:all, :conditions => ['user_id = ? or referrer_user_id = ?', User.find_by_email(params[:q]).id, User.find_by_email(params[:q]).id], :order => 'created_at DESC')
    elsif params[:q] =~ /\w+/
      @type = "Promotion Code"
      @credits = Credit.find(:all, :conditions => {:promotion_code_id => PromotionCode.find_by_code(params[:q]).id}, :order => 'created_at DESC')
    else
      @credits = Credit.find(:all, :order => 'created_at DESC', :limit => 20)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end

  # GET /credits/1
  # GET /credits/1.xml
  def show
    @credit = Credit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  # GET /credits/new
  # GET /credits/new.xml
  def new
    @credit = Credit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  # GET /credits/1/edit
  def edit
    @credit = Credit.find(params[:id])
  end

  # POST /credits
  # POST /credits.xml
  def create
    @credit = Credit.new(params[:credit])
    @credit.value = PromotionCode.find(params[:credit][:promotion_code_id]).value if params[:credit][:value].blank?
    @user = User.find_by_email(params[:user_email]) unless params[:user_email].blank?
    
    unless @user.nil?
      @credit.user = @user

      respond_to do |format|
        if @credit.save
          flash[:notice] = 'Credit was successfully created. It should be the first one listed below.'
          format.html { redirect_to admin_credits_path }
          format.xml  { head :ok }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
        end
      end
    else
      @credit.errors.add_to_base("Sorry, couldn't find user: #{params[:user_email]}.")
      render :action => "new"
    end
  end

  # PUT /credits/1
  # PUT /credits/1.xml
  def update
    @credit = Credit.find(params[:id])

    respond_to do |format|
      if @credit.update_attributes(params[:credit])
        flash[:notice] = 'Credit was successfully updated.'
        format.html { redirect_to admin_credits_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1
  # DELETE /credits/1.xml
  def destroy
    @credit = Credit.find(params[:id])
    @credit.destroy

    # this will eventually be done via AJAX
    redirect_to request.env['HTTP_REFERER'].blank? ? my_deals_path : :back
  end
end
