class Admin::BusinessPaymentsController < ApplicationController
  layout 'admin'
  before_filter :admin_required
  
  def index
    @finished_promotion_ids = Promotion.find(:all, :conditions => ['start_date <= ? and end_date <= ?', Time.zone.now, Time.zone.now]).collect{|p| p.id}
    
    @unsettled_payments = BusinessPayment.find(:all, :conditions => {:paid => false, :payment1_paid => false, :payment2_paid => false, :promotion_id => @finished_promotion_ids}).collect{|p| p.business_id}.uniq
    @partial_payments = BusinessPayment.find(:all, :conditions => {:payment1_paid => true, :payment2_paid => false, :promotion_id => @finished_promotion_ids}).collect{|p| p.business_id}.uniq
    @settled_payments = BusinessPayment.find(:all, :conditions => {:paid => true, :promotion_id => @finished_promotion_ids}).collect{|p| p.business_id}.uniq
    
    @unpaid_businesses = Business.find(:all, :conditions => {:id => @unsettled_payments}, :order => "name ASC")
    @partially_paid_businesses = Business.find(:all, :conditions => {:id => @partial_payments}, :order => "name ASC")
    @paid_businesses = Business.find(:all, :conditions => {:id => @settled_payments - @unsettled_payments - @partial_payments}, :order => "name ASC")
    
    if !params[:paid_business_id].blank?
      @promotions = Promotion.find(:all, :conditions => {:id => @finished_promotion_ids, :business_id => Business.find(params[:paid_business_id])}, :order => 'end_date DESC')
    elsif !params[:partially_paid_business_id].blank?
      @promotions = Promotion.find(:all, :conditions => {:id => @finished_promotion_ids, :business_id => Business.find(params[:partially_paid_business_id])}, :order => 'end_date DESC')
    elsif !params[:unpaid_business_id].blank?
      @promotions = Promotion.find(:all, :conditions => {:id => @finished_promotion_ids, :business_id => Business.find(params[:unpaid_business_id])}, :order => 'end_date DESC')
    else
      @promotions = []
    end
  end
  
  def update
    @business_payment = BusinessPayment.find(params[:id])
    
    if @business_payment.update_attributes(params[:business_payment])
      unless @business_payment.initial_amount > 0
        @business_payment.initial_amount = @business_payment.promotion.business_profit
      end
      
      if @business_payment.payment1_amount >= 0
        @business_payment.payment1_paid = true
      elsif @business_payment.payment2_amount >= 0 and @business_payment.payment1_paid?
        @business_payment.payment2_paid = true
      end
      
      if @business_payment.payment1_paid? and @business_payment.payment2_paid?
        @business_payment.paid = true
      end

      @business_payment.save
      
      flash[:notice] = "Payment for #{@business_payment.business.name} was updated. Good for you!"
    else
      flash[:error] = "And then....something went terribly wrong!!  Not sure what happened."
    end
    
    redirect_to :action => 'index', :paid_business_id => @business_payment.business_id, :partially_paid_business_id => @business_payment.business_id, :unpaid_business_id => @business_payment.business_id
  end
end
