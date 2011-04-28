class Admin::HomeController < ApplicationController
  layout 'admin'
  before_filter :staff_required, :except => ['login']

  def index
  end
  
  def login
    @user_session = UserSession.new
    @user = User.new
  end
  
  def impersonate
    if params[:type] == 'business'
      @business = Business.find(params[:id])
      current_user.admin.business_impersonation_id = @business.id
      @flash = "<strong>" + @business.name + "</strong>"
    elsif params[:type] == 'customer'
      @customer = Customer.find(params[:id])
      current_user.admin.customer_impersonation_id = @customer.id
      @flash = "<strong>" + @customer.name + "</strong>"
    else
      flash[:error] = "Something CRAZY happened. Please let matt@sowhatsthedeal.com know.  Thanks!"
      redirect_to admin_home_path
    end
    
    if current_user.admin.save
      flash[:notice] = "You are now impersonating: " + @flash + ". Have fun, but don't do anything foolish!"
    else
      flash[:error] = "It looks like you were trying to impersonate " + @flash + " but it didn't work. Email Rob or Matt for details."
    end
    
    redirect_to params[:type] == 'business' ? business_home_path : my_deals_path
  end

end