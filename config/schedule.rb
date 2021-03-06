# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:

every 1.hour, :at => 15 do
  command 'cd /home/kaliara/public_html/wtd/current/public/system/assets/kgb_vouchers && lftp -f download.lftp'
end

set :output, "log/cron_log.log"


# every 1.day, :at => '4:50 am' do
#   rake "coupons:activate"
# end
# 
# every 1.day, :at => '5:05 am' do
#   rake "coupons:email"
# end
# 
# every 1.day, :at => '8:05 am' do
#   rake "coupons:send_gifts"
# end
# 
# every 1.day, :at => '1:15 pm' do
#   rake "coupons:reminder"
# end
# 
# every 1.day, :at => '5:35 am' do
#   rake "cleanup:carts"
# end
# 
# every 4.hours do
#   rake "cleanup:cart_items"
# end
# 
every 1.hour, :at => 25 do
  rake "kgb:import_vouchers"
end
# 
# every 10.minutes do
#   rake "delayed_emails:email"
# end
# 
# every 27.minutes do
#   rake "subscriptions:update" 
# end
# 
# every 1.day, :at => '1:00 am' do
#   rake "reminders:email"
# end
# every 1.day, :at => '5:30 am' do
#   rake "reminders:email"
# end
# every 1.day, :at => '9:00 am' do
#   rake "reminders:email"
# end
# every 1.day, :at => '1:00 pm' do
#   rake "reminders:email"
# end
# every 1.day, :at => '5:00 pm' do
#   rake "reminders:email"
# end
# every 1.day, :at => '9:00 pm' do
#   rake "reminders:email"
# end



# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
