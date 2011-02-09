class PaymentProfilesController < ApplicationController
  before_filter :impersonate_customer
  before_filter :customer_required

  def destroy
    @payment_profile = current_user.payment_profile
    if !@payment_profile.nil? and @payment_profile.destroy
      flash[:notice] = "Credit Card was successfully removed"
    else
      flash[:error] = "There was a problem removing your credit card. Please try again or email us at support@sowhatsthedeal.com"
    end
    
    redirect_to request.env['HTTP_REFERER'].blank? ? new_purchase_path : :back 
  end
end