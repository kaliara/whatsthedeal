namespace :delayed_emails do
  desc "Sends a delayed email to a user"
  task :email => :environment do 
    @delayed_emails = DelayedEmail.find(:all, :conditions => ['emailed = ? and delay_until < ?', false, Time.zone.now])
    puts "Looks like there are #{@delayed_emails.size} delayed emails to send as of #{Time.zone.now}."

    @delayed_emails.each do |delayed_email|
      @user = User.find(delayed_email.user_id)
      unless @user.nil?
        unless @user.gets_daily_deal_email? and @user.changed_password?
          Notifier.send(delayed_email.template.to_sym, @user)
          puts "Delay-emailed the #{delayed_email.template} email to #{@user.email}."
        else
          puts "#{@user.email} updated their password and is on list, no email sent."
        end
      end
      delayed_email.emailed!
    end
  end
end