class Admin::RefundsController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => [:processing]

  # GET /refunds
  # GET /refunds.xml
  def index
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    @start_date = params[:start_date].nil? ? DateTime.new(@now.year, @now.month, 1, 4, 0) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(@now.year, @now.month, -1, 4, 0) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    @refunds = Refund.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @refunds }
    end
  end

  # GET /refunds/1
  # GET /refunds/1.xml
  def show
    @refund = Refund.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => "show"}
      format.xml  { render :xml => @refund }
    end
  end

  def new
    if session[:queued_coupon_refunds].blank? or params[:clear_queue] == 'true'
      session[:queued_coupon_refunds] = []
      flash[:error] = ""
    end
    
    if params[:coupon_to_remove] and !session[:queued_coupon_refunds].empty?
      session[:queued_coupon_refunds].delete(params[:coupon_to_remove])
    end
    
    if params[:coupon_to_refund] and (session[:queued_coupon_refunds].empty? or Coupon.find(params[:coupon_to_refund]).purchase_id == Coupon.find(session[:queued_coupon_refunds].first).purchase_id)
      session[:queued_coupon_refunds] << params[:coupon_to_refund]
    elsif session[:queued_coupon_refunds].empty?
      flash.now[:notice] = "This queue is for coupons that will be refunded. You can <a href='/admin/coupons'>search for coupons</a> to add to this queue"
    elsif params[:coupon_to_refund]
      flash.now[:error] = "Sorry, but you can only refund coupons that are part of the same purchase. Need to start over? You can <a href='?clear_queue=true'>clear the refund queue</a>."
    end
    
    @refund = Refund.new
    @queued_coupon_refunds = Coupon.find(session[:queued_coupon_refunds])
    @credit_amount = 0
    @cc_amount = 0
    
    unless @queued_coupon_refunds.empty?
      @credit_amount = @queued_coupon_refunds.first.purchase.credit_per_deal * @queued_coupon_refunds.size
      @cc_amount = @queued_coupon_refunds.collect{|c| c.deal.price}.sum - @credit_amount
    end
    
    if params[:all_credit]
      @credit_amount = @credit_amount + @cc_amount
      @cc_amount = 0
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @refund }
    end
  end

  # POST /refunds
  # POST /refunds.xml
  def create
    @refund = Refund.new(params[:refund])
    @queued_coupon_refunds = Coupon.find(session[:queued_coupon_refunds])
    
    # create wtd credits
    if @refund.credit_amount > 0
      @credit = Credit.new
      @credit.promotion_code_id = PromotionCode::REFUND_CREDIT
      @credit.value = @refund.credit_amount
      @credit.user_id = @refund.purchase.user.id
      @credit.save
      @refund.credit_id = @credit.id
    end
    
    
    # connect with authorize.net
    @connect = true
    
    if @connect
      # mark coupons as refunded
      @queued_coupon_refunds.each do |coupon|
        coupon.refunded = true
        coupon.save
      end
      
      # clear session
      session[:queued_coupon_refunds] = []
    end
    
    if @refund.save
      flash[:notice] = 'Refund was successfully saved.'
      redirect_to(admin_refund_path(@refund))
    else
      render :action => "new"
    end
  end

  def processing
    @refund = Refund.find(params[:id])
    @refund.processed = true
    
    if @refund.save
      Notifier.deliver_refund_processed(@refund)
      flash[:notice] = "Refund marked as processed and email sent to user"
    end
    
    redirect_to :back
  end
end
