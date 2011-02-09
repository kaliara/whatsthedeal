class Admin::DealsController < ApplicationController
  layout 'admin'
  before_filter :staff_required 
  
  # GET /deals
  # GET /deals.xml
  def index
    if params[:promotion_id]
      @promotion = Promotion.find(params[:promotion_id])
      @deals = @promotion.deals
    else
      @deals = Deal.find(:all, :order => "id desc")
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deals }
    end
  end

  # GET /deals/1
  # GET /deals/1.xml
  def show
    @deal = Deal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deal }
    end
  end

  # GET /deals/new
  # GET /deals/new.xml
  def new
    @deal = Deal.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deal }
    end
  end

  # GET /deals/1/edit
  def edit
    # @promotion = Promotion.find(params[:promotion_id])    
    @deal = Deal.find(params[:id])
  end

  # POST /deals
  # POST /deals.xml
  def create
    @deal = Deal.new(params[:deal])

    respond_to do |format|
      if @deal.save
        flash[:notice] = 'Deal was successfully created.'
        format.html { redirect_to admin_deals_path }
        format.xml  { render :xml => @deal, :status => :created, :location => @deal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deals/1
  # PUT /deals/1.xml
  def update
    @deal = Deal.find(params[:id])

    respond_to do |format|
      if @deal.update_attributes(params[:deal])
        flash[:notice] = 'Deal was successfully updated.'
        format.html { redirect_to admin_deals_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deals/1
  # DELETE /deals/1.xml
  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy

    respond_to do |format|
      format.html { redirect_to admin_deals_path }
      format.xml  { head :ok }
    end
  end
  
  def coupon_codes
    @deal = Deal.find(params[:deal_id])
    @num = params[:num].to_i > 0 ? params[:num].to_i : 100
    @coupon_codes = []
    
    # should match what is in Coupon.coupon_code function
    (1..@num).to_a.each do |i|
      @coupon_codes << @deal.coupon_code_prefix + (@deal.coupon_code_start + (@deal.coupon_code_delta * i)).to_s(@deal.coupon_code_number_base).upcase
    end
  end
  
  # email and activate coupons
  def activate_coupons
    @deal = Deal.find(params[:id])
    @users = []

    if @deal.promotion.quota_met?
      flash[:notice] = "<strong>Coupon Script Good News</strong>:"
      flash[:error]  = "<strong>Coupon Script Bad News</strong>:"

      @deal.coupons.inactive.each do |coupon|  
        if coupon.activate!
          @users << coupon.user
        end
      end
    else
      flash[:error] = "This deal's promotion has NOT reached its quota. I am not sure how you even got here in the first place."
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
end
