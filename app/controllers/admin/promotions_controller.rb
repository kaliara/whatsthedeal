class Admin::PromotionsController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /promotions
  # GET /promotions.xml
  def index
    if params[:live] == 'true'
      @promotions = Promotion.find(:all, :order => 'start_date desc').delete_if{|p| !p.active?}
    else
      @promotions = Promotion.find(:all, :order => 'id desc', :limit => (params[:all] ? nil : 25))
    end
    
    @next_featured = Promotion.find(:first, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ?', Time.now.utc + 1.day, Time.now.utc + 1.day, true, false], :order => 'featured DESC, start_date DESC')

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
    session[:return_to] = nil
  end

  # POST /promotions
  # POST /promotions.xml
  def create
    @promotion = Promotion.new(params[:promotion])
    @promotion.active = false
    @promotion.end_date = @promotion.start_date + params[:duration].to_i.days + params[:end_time].to_i.hours
    @promotion.ad_description4 = @promotion.name
    @promotion.ad_description5 = @promotion.name
    @promotion.ad_description6 = @promotion.name
    @promotion.ad_description7 = @promotion.name
    
    respond_to do |format|
      if @promotion.save

        # create business payment
        @business_payment = BusinessPayment.new
        @business_payment.promotion_id = @promotion.id
        @business_payment.business_id = @promotion.business.id
        @business_payment.save
        
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
        unless params[:duration].blank?
          @promotion.end_date = (@promotion.start_date.to_time + params[:duration].to_i.days + params[:end_time].to_i.hours).to_datetime
          @promotion.save
        end
        
        flash[:notice] = 'Promotion was successfully updated.'
        format.html { redirect_to session[:return_to].blank? ? edit_admin_promotion_path(@promotion) : session[:return_to] }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @promotion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def ad_preview
    @promotion = Promotion.find(params[:id])
    session[:return_to] = admin_ad_preview_path(:id => @promotion)
  end

  def sort
    Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and id != ?', Time.now.utc, Time.now.utc, true, false, Promotion.featured.first]).each do |p|
      p.position = params['promotion'].index(p.id.to_s) + 1
      p.save
    end
    render :nothing => true
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.xml
  def destroy
    @promotion = Promotion.find(params[:id])

    BusinessPayment.find(:all, :conditions => {:promotion_id => @promotion.id}).each do |bp|
      bp.destroy
    end
    
    @promotion.destroy

    respond_to do |format|
      format.html { redirect_to admin_promotions_path }
      format.xml  { head :ok }
    end
  end
  
  
  # active and email coupons
  def activate_coupons
    @promotion = Promotion.find(params[:id])
    @users = []

    if @promotion.quota_met?
      flash[:notice] = "<strong>Coupon Script Good News</strong>:"
      flash[:error]  = "<strong>Coupon Script Bad News</strong>:"

      @promotion.deals.each do |deal|
        deal.coupons.inactive.each do |coupon|  
          if coupon.activate!
            @users << coupon.user
          end
        end
      end
    else
      flash[:error] = "This promotion has NOT reached its quota. I am not sure how you even got here in the first place."
    end
    
    @users.each do |user|
      coupons_to_email = []
      user.coupons.each do |coupon|
        if coupon.active? and !coupon.emailed?
          coupons_to_email << coupon
          coupon.emailed!
        end
      end
      
      unless coupons_to_email.empty? or !user.gets_coupon_ready_email?
        if Notifier.deliver_coupons_ready_notification(user, coupons_to_email)
          flash[:notice] += "<br/>#{user.email} was emailed #{coupons_to_email.size} coupon(s): #{coupons_to_email.collect{|c| c.name}.join(',')}"
        else
          flash[:error] += "<br/>CRAP! There was a problem emailing #{coupons_to_email.size} coupon(s) to #{user.email}. Should probably email Rob or Matt (matt@sowhatsthedeal.com) about this."
        end
      end
    end
    
    if @users.empty?
      flash[:error] += '<br/>Seems like there were no new coupons to activate'
    end
  end

  # sidebar promotion sorting
  def sidebar
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and id != ?', Time.now.utc, Time.now.utc, true, false, 0], :order => 'position')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @promotions }
    end
  end
end
