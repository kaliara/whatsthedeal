class Admin::UserReviewsController < ApplicationController
  layout 'admin'
  before_filter :admin_required 
  
  def index
    @user_reviews = UserReview.find(:all, :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_reviews }
    end
  end
  
  def update
    @user_review = UserReview.find(params[:id])
    @user_review.reviewed = true
    @user_review.credit_given = params[:credit_given]
    @user_review.save
    
    if @user_review.credit_given?
      @promotion_code = PromotionCode.find_by_user_id(@user_review.user_id)
      @credit = Credit.new
      @credit.promotion_code_id = @promotion_code.id
      @credit.value = @promotion_code.value
      @credit.user_id = @user_review.referred_user_id
      @credit.referrer_user_id = @user_review.user_id
      @credit.save
    end
    
    redirect_to :action => 'index'
  end
end