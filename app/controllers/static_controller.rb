class StaticController < ApplicationController
  before_filter :impersonate_customer, :check_origin, :force_full_site
  before_filter :customer_required, :only => ['totn_code']
  layout :hyrbrid_layout_application

  @pages = %W(how_it_works faq info contact about suggest_business referral_info signup signup2 signup3 signup4 press survey biz special_event special_event2 special_event3 special_event4 special_event5 happyhour happyhour2 marchmadness raffle raffle2 raffle3 raffle4 raffle5 raffle6 raffle7 raffle8 raffle9 raffle10 raffle11 raffle12 raffle13 raffle13 raffle14 raffle15 rap mobile_info contact_hpdc faq_hpdc timeout_error totn_code)
  
  @pages.each do |page|
    define_method page do
      if current_user
        @user = current_user
      else
        @user = User.new
        @user.customer = Customer.new
      end
      @side_promotions = Promotion.sidebar
    end
  end

  def terms
    render :action => 'terms'
  end
  
  def full_version
    session[:force_full_site] = true
    redirect_to request.env['HTTP_REFERER'].blank? ? root_url : :back
  end

  def mobile_version
    session[:force_full_site] = false
    redirect_to request.env['HTTP_REFERER'].blank? ? root_url : :back
  end
end