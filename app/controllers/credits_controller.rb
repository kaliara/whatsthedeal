class CreditsController < ApplicationController
  before_filter :impersonate_customer
  before_filter :customer_required, :except => [:redeem_gift]
  layout :hyrbrid_layout_application

  # POST /credits
  # POST /credits.xml
  def create
    @current_user = current_user
    @credit = Credit.new
    
    @credit.promotion_code = PromotionCode.find_by_code(params[:code].downcase) unless params[:code].downcase.blank?
    
    if params[:code].blank?
      flash[:error] = "Doesn't look like you entered a promo code."
      redirect_to new_purchase_path
    elsif @credit.promotion_code.nil?
      flash[:error] = "Could not find that promo code. Try again?"
      redirect_to new_purchase_path(:code => params[:code])
    elsif @credit.restricted?
      flash[:error] = "Sorry, you can only use that promo code during registration."
      redirect_to new_purchase_path(:code => params[:code])
    else
      @credit.value = @credit.promotion_code.value 
      @credit.user_id = @current_user ? @current_user.id : nil
      @credit.cart_id = cart.id
      @credit.referrer_user_id = @credit.promotion_code.user_id
      
      if @credit.promotion_code.gifted_credit?
        if @credit.save
          flash[:notice] = "You're all set! WTD credit has been loaded into your account and you're good to start shopping."
          redirect_to promotions_path
        else
          flash[:error] = "There seems to be a problem with your credit gift. Have you already used it? If not, email us at support@sowhatsthedeal.com"
          render :action => 'redeem_gift'
        end
      else
        if @credit.save
          flash[:notice] = "The #{@credit.promotion_code.name} promo was successfully applied."
          redirect_to new_purchase_path
        else
          flash[:error] = @credit.errors.on(:promotion_code).to_s + @credit.errors.on(:referral).to_s
          redirect_to new_purchase_path(:code => params[:code])
        end
      end
    end
  end
  
  def redeem_gift
    unless current_user
      redirect_away('/login')
      flash[:notice] = "In order to redeem your gift, you must first login or create an account"
    else
      @promotion_code = PromotionCode.find_by_code(params[:code]) unless params[:code].blank?
      @credit = Credit.new
    
      if @promotion_code.nil? or !@promotion_code.redeemable?
        redirect_to root_url
      else
        render :action => 'redeem_gift'
      end
    end
  end
end