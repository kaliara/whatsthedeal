namespace :kgb do
  require 'fileutils'

  desc "Imports the KGB vouchers into the kgb_coupons table"
  task :import_vouchers => :environment do
  
    Dir.glob(File.join("**","public/system/assets/kgb_vouchers","*.csv"))[-3..-1].each do |file|
      File.open(file,'r') do |f|
        f.each do |line|
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
  
end