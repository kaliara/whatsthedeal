class Admin::PromotionCodesController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  
  # GET /promotion_codes
  # GET /promotion_codes.xml
  def index
    if params[:q] =~ /\@/
      @type = "email"
      @user = User.find_by_email(params[:q])
      @promotion_codes = @user.nil? ? [] : PromotionCode.find(:all, :conditions => {:user_id => @user.id}, :order => 'name asc')
    elsif params[:q] =~ /\w+/
      @type = "code"
      @promotion_codes = PromotionCode.find(:all, :conditions => ["code like ?", "%#{params[:q]}%"], :order => 'name asc')
    else
      @promotion_codes = params[:all] ? PromotionCode.find(:all, :order => 'name asc') : PromotionCode.find(:all, :conditions => {:listed => true}, :order => 'name asc')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @promotion_codes }
    end
  end

  # GET /promotion_codes/1
  # GET /promotion_codes/1.xml
  def show
    @promotion_code = PromotionCode.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @promotion_code }
    end
  end

  # GET /promotion_codes/new
  # GET /promotion_codes/new.xml
  def new
    @promotion_code = PromotionCode.new
    @promotion_code.listed = true

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @promotion_code }
    end
  end

  # GET /promotion_codes/1/edit
  def edit
    @promotion_code = PromotionCode.find(params[:id])
  end

  # POST /promotion_codes
  # POST /promotion_codes.xml
  def create
    @promotion_code = PromotionCode.new(params[:promotion_code])
    @promotion_code.name = @promotion_code.name.capitalize
    @promotion_code.code = @promotion_code.code.downcase
    @promotion_code.use_limit ||= 99999
    @promotion_code.user_id = current_user.id

    respond_to do |format|
      if @promotion_code.save
        flash[:notice] = 'PromotionCode was successfully created.'
        format.html { redirect_to admin_promotion_codes_path }
        format.xml  { render :xml => @promotion_code, :status => :created, :location => @promotion_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @promotion_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /promotion_codes/1
  # PUT /promotion_codes/1.xml
  def update
    @promotion_code = PromotionCode.find(params[:id])

    respond_to do |format|
      if @promotion_code.update_attributes(params[:promotion_code])
        flash[:notice] = 'PromotionCode was successfully updated.'
        format.html { redirect_to admin_promotion_codes_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @promotion_code.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def unlist
    @promotion_code = PromotionCode.find(params[:id])
    @promotion_code.unlist!
    
    render :text => @promotion_code.id
  end
    
  # DELETE /promotion_codes/1
  # DELETE /promotion_codes/1.xml
  # def destroy
  #   @promotion_code = PromotionCode.find(params[:id])
  #   @promotion_code.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(promotion_codes_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
