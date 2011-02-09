namespace :reminders do

  desc "Sends a reminder email to user about soon ending promotion"
  task :email => :environment do 
    @near_sellout_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ?', Date.today, Date.today, true]).delete_if{|p| !p.near_sellout?}
    puts "Looks like there are #{@near_sellout_promotions.size} promotions near sellout."

    unless @near_sellout_promotions.empty?
      Reminder.find(:all, :conditions => {:promotion_id => @near_sellout_promotions.collect{|p| p.id}, :emailed => false}).each do |reminder|
        Notifier.deliver_promotion_reminder_near_sellout(reminder)
        reminder.emailed!
        puts "Emailed Promotion ##{reminder.promotion_id} reminder (near sellout) to #{reminder.email}."
      end
    end
    
    @ending_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and end_date < ? and active = ?', Time.now.utc, Time.now.utc, Time.now.utc + 37.hours, true])
    puts "Looks like there are #{@ending_promotions.size} promotions about to end."

    unless @ending_promotions.empty?
      Reminder.find(:all, :conditions => {:promotion_id => @ending_promotions.collect{|p| p.id}, :emailed => false}).each do |reminder|
        Notifier.deliver_promotion_reminder(reminder)
        reminder.emailed!
        puts "Emailed Promotion ##{reminder.promotion_id} reminder (ending) to #{reminder.email}."
      end
    end
  end
  
end