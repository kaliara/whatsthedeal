# action mailer settings (sendgrid)
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address        => "smtp.sendgrid.net",
  :port           => "25",
  :authentication => :plain,
  :user_name      => "matt@sowhatsthedeal.com",
  :password       => "x.ab0x.ab0",
  :domain         => "sowhatsthedeal.com",
}