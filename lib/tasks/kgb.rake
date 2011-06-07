namespace :kgb do
  require 'fileutils'

  desc "Imports the KGB vouchers into the kgb_coupons table"
  task :import_vouchers => :environment do
  
    Dir.glob(File.join("**","public/system/assets/kgb_vouchers/KGB_Vouchers","*.csv")).sort.reverse[0..5].each do |file|
      File.open(file,'r') do |f|
        f.each do |line|
          line = line.gsub("\\,","")
          @kgb_coupon = KgbCoupon.new
          @kgb_coupon.date_exported = line.split(",")[0]
          @kgb_coupon.transactions_transaction_id = line.split(",")[1]
          @kgb_coupon.transactions_deal_id = line.split(",")[2]
          @kgb_coupon.transactions_user_id = line.split(",")[3]
          @kgb_coupon.transactions_quantity = line.split(",")[4]
          @kgb_coupon.transactions_total_amount = line.split(",")[5]
          @kgb_coupon.transactions_timestamp = line.split(",")[6]
          @kgb_coupon.users_first_name = line.split(",")[7]
          @kgb_coupon.users_last_name = line.split(",")[8]
          @kgb_coupon.users_email = line.split(",")[9]
          @kgb_coupon.deals_merchant_id = line.split(",")[10]
          @kgb_coupon.deals_title = line.split(",")[11]
          @kgb_coupon.deals_price = line.split(",")[12]
          @kgb_coupon.deals_coupon_expires = line.split(",")[13]
          @kgb_coupon.merchants_name = line.split(",")[14]
          @kgb_coupon.save
        end
      end
    end
  end

  # task :export_analytics, :days => :environment do
  #   @days = args.days.nil? ? 1 : 7
  #   @data = []
  #   
  #   if @days == 1
  #     @start_date = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 4, 0)
  #   elsif @days == 7
  #     @start_date = DateTime.parse(Date.commercial(Date.today.year, Date.today.cweek, 1).strftime("%m/%d/%Y") + " 04:00:00")
  #   end
  #   
  #   for i in 0..(@days - 1)
  #     @registrations = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
  #     @referrals = User.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days]).delete_if{|u| Credit.find(:all, :conditions => ['user_id = ? and referrer_user_id > 0', u.id]).size == 0}
  #     @subscriptions = User.find(:all, :conditions => ['created_at >= ? and created_at < ? and gets_daily_deal_email = ?', @start_date + i.days, @start_date + (i + 1).days, true])
  #     @purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
  #     @first_purchases = Purchase.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days]).delete_if{|p| p.id != Purchase.find(:first, :conditions => ['user_id = ?', p.user_id], :order => 'created_at ASC').id}
  #     @deals = Coupon.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date + i.days, @start_date + (i + 1).days])
  #     @revenue = @purchases.collect{|p| p.deals_total}.sum
  #     @revenue_post_credit = @purchases.collect{|p| p.total}.sum
  #     @profit = @purchases.collect{|p| p.profit}.sum
  #     
  #     @data[i] = [(@start_date + i.days).strftime("%m/%d/%Y"), @registrations.size, @referrals.size, @subscriptions.size, @purchases.size, @first_purchases.size, @deals.size, @purchases.collect{|p| p.early_bird_losses}.sum, @revenue, @revenue_post_credit, @profit - (@revenue - @revenue_post_credit), @deals.empty? ? 0 : @revenue / @deals.size, @revenue > 0 ? @profit / @revenue : 0]
  #   end
  #   
  #   headers = "Date,Registrations,Referred Registrations,Subscriptions,Purchases,First Purchases,Deals,Early bird losses,Revenue,Revenue (after credits),Profit,Avg. Rev. per Coupon,Avg. Commission"
  #   for i in 0..(@days - 1) do
  #     @data[i].join(',')
  #   end
  #   
  #   File.open(file,'w') do |f|
  #     f.each do |line|
  #     end
  #   end
  # end
  
end