class Business::CouponsController < ApplicationController
  layout 'business', :except => :show
  before_filter :impersonate_business
  before_filter :business_required

  def show
    if params[:sample_for_deal].to_i > 0
      @coupon = Coupon.sample(params[:sample_for_deal].to_i, params[:redeemed], params[:gift])
      render :action => 'show'
    else
      redirect_to business_home_path
    end  
  end

end