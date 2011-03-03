class Notifier < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default_url_options[:host] = "sowhatsthedeal.com"
  TEST_RECIPIENT = "testing@sowhatsthedeal.com"
  TESTING = (RAILS_ENV == 'staging' or RAILS_ENV == 'development')
  
  def signup_confirmation(user)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Welcome to What's the Deal DC" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user, :google_tracking => "?utm_source=signupemail&utm_medium=email"
   content_type "text/html"
  end
  
  def purchase_confirmation(user, purchase)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Your recent purchase from What's the Deal" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user, :purchase => purchase
   content_type "text/html"
  end
  
  def coupons_ready_notification(user, coupons)
   recipients  (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Your coupons are ready at What's the Deal" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user, :coupons => coupons
   content_type "text/html"
  end
  
  def coupon_gifted_credit_received(coupon)
   recipients  (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : coupon.gift_email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "You Have WTD Credit from #{coupon.gift_from} on What's the Deal" + (" ::::: [originally for #{coupon.gift_email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :coupon => coupon
   content_type "text/html"
  end

  def coupon_gift_received(coupon)
   recipients  (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : coupon.gift_email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "You Have a Gift from #{coupon.gift_from} on What's the Deal" + (" ::::: [originally for #{coupon.gift_email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :coupon => coupon
   content_type "text/html"
  end

  def coupon_gift_sent(coupon)
   recipients  (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : coupon.user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Gift Sent to #{coupon.gift_name}" + (" ::::: [originally for #{coupon.user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :coupon => coupon
   content_type "text/html"
  end

  def coupons_expiring_reminder(coupon)
   recipients  (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : coupon.user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Your coupon is about to expire at What's the Deal" + (" ::::: [originally for #{coupon.user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => coupon.user, :coupon => coupon
   content_type "text/html"
  end

  def password_reset_instructions(user)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Reset your What's the Deal Password" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user, :edit_password_reset_url => reset_password_url(user.perishable_token)
   content_type "text/html"
  end
  
  def new_old_user(user)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Your WTD Account" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user, :edit_password_reset_url => reset_password_url(user.perishable_token)
   content_type "text/html"
  end 
   
  def sub_come_back(user)
    recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
    from         "support@sowhatsthedeal.com (What's the Deal)"
    subject      (user.credit_total > 0 ? "Come Try WTD and use your $#{user.credit_total.to_i} credit" : "Come Try WTD and get $3 off your first purchase") + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
    body         :user => user
    content_type "text/html"
  end

  def promotion_reminder(reminder)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : reminder.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Reminder: #{reminder.promotion.name} expires tomorrow" + (" ::::: [originally for #{reminder.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :reminder => reminder, :promotion => reminder.promotion
   content_type "text/html"
  end

  def promotion_reminder_near_sellout(reminder)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : reminder.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Almost Sold Out: #{reminder.promotion.name}!" + (" ::::: [originally for #{reminder.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :reminder => reminder, :promotion => reminder.promotion
   content_type "text/html"
  end
  
  def referral_notification(referral)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : referral.user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "You Just Earned $5 in WTD Credit" + (" ::::: [originally for #{referral.user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => referral.user
   content_type "text/html"
  end

  def user_review_added(user_review)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : "referral@sowhatsthedeal.com"
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "User Review # #{user_review.id} Added" + (" ::::: [just a test]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user_review => user_review
   content_type "text/html"
  end
  
  # special for washingtonian
  def washingtonian_signup_confirmation(user)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Welcome to Washingtonian Deals" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user
   content_type "text/html"
  end
  
  # special for halfpricedc
  def halfpricedc_signup_confirmation(user)
   recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
   from         "support@sowhatsthedeal.com (What's the Deal)"
   subject      "Welcome to Half Price DC" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
   body         :user => user
   content_type "text/html"
  end
  

  # special for sloopy
  def sloopy_purchase_confirmation(user, purchase)
    recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
    from         "support@sowhatsthedeal.com (What's the Deal)"
    subject      "Your recent purchase from What's the Deal" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
    body         :user => user, :purchase => purchase
    content_type "text/html"
  end
  
  def sloopy_coupon(user, purchase)
    recipients   (RAILS_ENV == 'staging' or RAILS_ENV == 'development') ? TEST_RECIPIENT : user.email
    from         "support@sowhatsthedeal.com (What's the Deal)"
    subject      "Your Coupon from What's the Deal" + (" ::::: [originally for #{user.email}]" if (RAILS_ENV == 'staging' or RAILS_ENV == 'development')).to_s
    body         :user => user, :purchase => purchase
    content_type "text/html"
  end
  
end