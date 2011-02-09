namespace :coupons do
  desc "Activates coupons whose promotion has reached its quota"
  task :activate => :environment do
    Promotion.all.each do |promotion|
      puts "Checking quota of promotion: #{promotion.name}"
      if promotion.purchases >= promotion.quota
        puts "This promotion has reached its quota"
        promotion.deals.each do |deal|
          deal.coupons.inactive.each do |coupon|  
            if coupon.activate!
              puts coupon.name + " ACTIVATED FOR " + coupon.user.customer.name
            end
          end
        end
      end
    end
  end

  desc "Emails coupons that are activated and marks them as emailed"
  task :email => :environment do
    User.all.each do |user|
      coupons_to_email = []
      user.coupons.each do |coupon|
        if coupon.active? and !coupon.emailed? and !coupon.gift? and !coupon.shippable?
          coupons_to_email << coupon
          coupon.emailed!
        end
      end
      
      unless coupons_to_email.empty? or !user.gets_coupon_ready_email?
        Notifier.deliver_coupons_ready_notification(user, coupons_to_email)
        puts "Emailed coupon for #{user.email}."
      end
    end
  end

  desc "Emails gift coupons to gift recipient and marks coupons as emailed"
  task :send_gifts => :environment do
    Coupon.find(:all, :conditions => ['gift = ? and active = ? and emailed = ? and gift_send_date <= ? and gift_email is not null', true, true, false, DateTime.new(Date.today.year, Date.today.month, Date.today.day,23,59,0)]).each do |coupon|
      if coupon.gifted_credit?
        Notifier.deliver_coupon_gifted_credit_received(coupon)        
      else
        Notifier.deliver_coupon_gift_received(coupon)
      end
      Notifier.deliver_coupon_gift_sent(coupon)
      coupon.emailed!
      puts "Emailed gift to #{coupon.gift_email}."
    end
  end

  desc "Emails coupons that are about to expire"
  task :reminder => :environment do
    Coupon.find(:all, :conditions => ['used = ? and active = ? and reminded = ? and gift = ? and expiration > ? and expiration < ?', false, true, false, false, Date.today, Date.today + 10.days], :group => 'user_id, deal_id').each do |coupon|
      if coupon.user.gets_coupon_expiring_email? and !coupon.reminded?
        Notifier.deliver_coupons_expiring_reminder(coupon)
        puts "Reminded #{coupon.user.email} about coupon expiration for #{coupon.name}."
      end

      Coupon.find(:all, :conditions => {:user_id => coupon.user_id, :deal_id => coupon.deal_id}).each do |c|
        c.reminded!
      end
      puts "Set reminded for all of #{coupon.user.email} for #{coupon.name}."
    end
  end
end