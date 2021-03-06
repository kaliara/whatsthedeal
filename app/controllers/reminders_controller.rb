class RemindersController < ApplicationController

  def create
    unless current_user
      flash[:error] = "Please log in or quickly create an account to use the reminder feature."
      redirect_away(login_path)
      return false
    else
      @reminder = Reminder.new
      @reminder.promotion_id = params[:reminder_promotion_id]
      @reminder.email = current_user.email

      @from_index = params[:from_index] == 'true'

      if @reminder.save
        session[:add_reminder] = true
      else
        flash[:error] = "Hmmm... something seems to be wrong with your email address for the reminder. Verify your address in <a href='/my_account'>your account</a>."
      end

      redirect_to @from_index ? promotions_path : promotion_slug_path(Promotion.find(params[:reminder_promotion_id]).slug)
    end
  end
  
  def destroy
    @reminder = Reminder.find(:first, :conditions => {:promotion_id => params[:reminder_promotion_id], :email => params[:reminder_email]})
    session[:remove_reminder] = true
    flash[:notice] = "Your reminder was successfully removed!" if @reminder.destroy
    
    redirect_to promotion_slug_path(Promotion.find(params[:reminder_promotion_id]).slug)
  end

end
