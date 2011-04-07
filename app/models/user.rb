class User < ActiveRecord::Base
  acts_as_authentic
  include ActiveMerchant::Utils
  
  WTD_MASTER_LIST = '44'
  WASHINGTONIAN_LIST = '51'
  HALFPRICEDC_LIST = '95'
  HAPPY_HOUR_LIST = '74'
  VIRGINIA_DEAL_LIST = '115'
  MARYLAND_DEAL_LIST = '116'
  
  has_one  :cart
  has_many :purchases
  has_many :coupons
  has_many :credits
  has_many :promotion_codes
  has_many :user_reviews

  has_one  :staff
  has_one  :admin
  has_one  :business
  has_one  :business_staff
  has_one  :customer
  has_one  :payment_profile
  
  belongs_to :origin
  
  accepts_nested_attributes_for :admin, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  accepts_nested_attributes_for :business, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  accepts_nested_attributes_for :customer, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  
  validates_presence_of     :email, :on => :save, :message => "can't be blank"
  validates_presence_of     :password, :on => :create, :message => "can't be blank"
  
  before_create :mistyped_email?  
  after_create :generate_referral_link, :send_signup_confirmation, :if => proc { |obj| obj.customer? }
  before_destroy :delete_cim_profile
  
  # special authorize.net cim methods
  def create_cim_profile
    #Login to the gateway using your credentials in environment.rb
    @gateway = get_payment_gateway
  
    #setup the user object to save (user_profile is defined below)
    @user = {:profile => user_profile}
  
    #send the create message to the gateway API
    response = @gateway.create_customer_profile(@user)

    if response.success? and response.authorization
      # actually update our user record with cim id
      self.customer_cim_id = response.authorization
      return self.save
    else
      return false
    end

  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def update_cim_profile
    if not self.customer_cim_id
      return false
    end
    @gateway = get_payment_gateway
  
    response = @gateway.update_customer_profile(:profile => user_profile.merge({
        :customer_profile_id => self.customer_cim_id
      }))

    if response.success?
      return true
    else
      return false
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def delete_cim_profile
    if not self.customer_cim_id
      return false
    end
    @gateway = get_payment_gateway
  
    response = @gateway.delete_customer_profile(:customer_profile_id => self.customer_cim_id)
  
    if response.success?
      return true
    else
      return false
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def user_profile
    return {:merchant_customer_id => self.id, :email => self.email, :description => self.customer? ? self.customer.name : self.email}
  end
  
  def staff?
    !self.admin.nil? or !self.staff.nil?
  end
  
  def admin?
    !self.admin.nil?
  end
  
  def business?
    !self.business.nil?
  end
  
  def business_staff?
    !self.business_staff.nil? or !self.business.nil?
  end
  
  def customer?
    !self.customer.nil?
  end
  
  def credit_total
    self.credits.redeemable.collect{|c| c.value.to_f}.to_a.sum
  end
  
  def referral_link
    PromotionCode.find_by_user_id(self.id).nil? ? "not_found" : PromotionCode.find_by_user_id(self.id).code
  end
  
  def referrals
    Credit.find(:all, :conditions => ['referrer_user_id = ? and user_id is not null', self.id])
  end
  
  def temporary_password
    phrase = "wtd4life"
    Digest::MD5.hexdigest(self.email.reverse + phrase)[1..10]
  end
  
  def changed_password?
    !valid_password?(temporary_password)
  end
  
  def send_signup_confirmation
    # if self.quietly_created?
      @delayed_email = DelayedEmail.new
      case self.partner_id
      when 2
        @delayed_email.template = 'deliver_washingtonian_signup_confirmation'
      when 3
        @delayed_email.template = 'deliver_halfpricedc_signup_confirmation'
      else
        @delayed_email.template = 'deliver_signup_confirmation'
      end
      @delayed_email.user_id = self.id
      @delayed_email.delay_until = self.created_at + (self.quietly_created? ? 30.minutes : 5.minutes)
      @delayed_email.save
    # else
    #   case self.partner_id
    #   when 2
    #     Notifier.deliver_washingtonian_signup_confirmation(self) unless self.gets_daily_deal_email?
    #   when 3
    #     Notifier.deliver_halfpricedc_signup_confirmation(self) unless self.gets_daily_deal_email?
    #   else
    #     Notifier.deliver_signup_confirmation(self) unless self.gets_daily_deal_email?
    #   end
    # end
  rescue Timeout::Error => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/> You might not get a confirmation email, but your account should be created and you should be logged in. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def deliver_password_reset_instructions!
    if self.save
      # reset_perishable_token!
      Notifier.deliver_password_reset_instructions(self)
    end
  rescue Timeout::Error => e
    return false
  end
  
  def deliver_new_old_user!
    # reset_perishable_token!
    Notifier.deliver_new_old_user(self)
  end
  
  def attending?(event)
    !Attendee.find(:all, :conditions => {:event_id => event.id, :user_id => self.id}).empty?
  end
  
  def entered?(raffle)
    !Entry.find(:all, :conditions => {:raffle_id => raffle.id, :user_id => self.id}).empty?
  end
  
  def generate_referral_link
    @personal_code = PromotionCode.new
    @personal_code.name = "Referral from #{self.customer.first_name == Customer::STOCK_FIRST_NAME ? 'a friend' : (self.customer.first_name + ' ' + self.customer.last_name)}"
    @personal_code.user_id = self.id
    @personal_code.code = self.email.downcase[0..4].gsub(/\@|\_|\./,'') + self.id.to_s
    @personal_code.restricted = PromotionCode.find(PromotionCode::REFERRAL_CREDIT).restricted
    @personal_code.value = PromotionCode.find(PromotionCode::REFERRAL_CREDIT).value.to_f
    @personal_code.use_limit = PromotionCode.find(PromotionCode::REFERRAL_CREDIT).use_limit
    @personal_code.save  
  end

  # mailboto stuff
  def update_subscriptions(request_uri='unknown', list=nil, delayed=false)
    success = true
    
    if self.changes['gets_happy_hour_announcement_email']
      if delayed
        @delayed_subscription = DelayedSubscription.new(:email => self.email, :list => User::HAPPY_HOUR_LIST, :referrer => request_uri)
        success = false unless @delayed_subscription.save
      else
        unless mailboto_api_request(request_uri, User::HAPPY_HOUR_LIST, self.changes['gets_happy_hour_announcement_email'].last == false)
          self.gets_happy_hour_announcement_email = self.changes['gets_happy_hour_announcement_email'].first unless self.changes['gets_happy_hour_announcement_email'].nil?
          success = false
        end
      end
    end
    
    if self.changes['gets_va_daily_deal_email']
      if delayed
        @delayed_subscription = DelayedSubscription.new(:email => self.email, :list => VIRGINIA_DEAL_LIST, :referrer => request_uri)
        success = false unless @delayed_subscription.save
      else
        unless mailboto_api_request(request_uri, daily_deal_list, self.changes['gets_va_daily_deal_email'].last == false)
          self.gets_daily_deal_email = self.changes['gets_va_daily_deal_email'].first unless self.changes['gets_va_daily_deal_email'].nil?
          success = false
        end
      end
    end  

    if self.changes['gets_md_daily_deal_email']
      if delayed
        @delayed_subscription = DelayedSubscription.new(:email => self.email, :list => MARYLAND_DEAL_LIST, :referrer => request_uri)
        success = false unless @delayed_subscription.save
      else
        unless mailboto_api_request(request_uri, daily_deal_list, self.changes['gets_md_daily_deal_email'].last == false)
          self.gets_daily_deal_email = self.changes['gets_md_daily_deal_email'].first unless self.changes['gets_md_daily_deal_email'].nil?
          success = false
        end
      end
    end  

    if self.changes['gets_daily_deal_email']
      case self.partner_id
      when 2
        daily_deal_list = User::WASHINGTONIAN_LIST
      when 3
        daily_deal_list = User::HALFPRICEDC_LIST
      else
        daily_deal_list = User::WTD_MASTER_LIST
      end

      if delayed
        @delayed_subscription = DelayedSubscription.new(:email => self.email, :list => daily_deal_list, :referrer => request_uri)
        success = false unless @delayed_subscription.save
      else
        unless mailboto_api_request(request_uri, daily_deal_list, self.changes['gets_daily_deal_email'].last == false)
          self.gets_daily_deal_email = self.changes['gets_daily_deal_email'].first unless self.changes['gets_daily_deal_email'].nil?
          success = false
        end
      end
    end  
    errors.add(:base,"The interns are out to lunch (something broke during the subscription process)! You can try updating your subscriptions by using the Email Preferences tab on the My Account page in a few minutes.") unless success
    
    unless list.to_i == 0
      if delayed
        @delayed_subscription = DelayedSubscription.new(:email => self.email, :list => list, :referrer => request_uri)
        success = false unless @delayed_subscription.save
      else
        unless mailboto_api_request(request_uri, list.to_s, false)
          errors.add(:base,"The interns are out to lunch (something broke during the subscription process)! Please email support@sowhatsthedeal.com to make sure you are RSVP'd for this event.  Thanks!") unless success
        end
      end
    end
    
    return success
  end
  
  def mailboto_api_request(referer, list, unsubscribe)
    host = 'www.mailboto.com'
    useragent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
    path = '/cgi-bin/uls/uls.cgi?ulsSubs=356=' + list
    http = Net::HTTP.new(host, 80)
    resp, data = http.get2(path, {'User-Agent' => useragent})
    headers = { 'Referer' => referer, 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => useragent }
    data =  "email=" + self.email
    if unsubscribe
      data += "&unsubs=1"
    else
      data += "&fname=#{self.customer.first_name}" unless (self.customer.first_name.blank? or self.customer.first_name == Customer::STOCK_FIRST_NAME)
      data += "&lname=#{self.customer.last_name}"  unless (self.customer.last_name.blank?  or self.customer.last_name  == Customer::STOCK_LAST_NAME)
      data += "&c4=#{self.customer.zipcode}" unless self.customer.zipcode.blank?
    end
    
    begin
      resp, data = http.post2(path, data, headers) unless (RAILS_ENV == 'development' or RAILS_ENV == 'staging')
      return true
    rescue
    	return false
    end
  end
  
  def mistyped_email?
    if email =~ /\.con|\.coom|\.cm$|\.cmo|gmial|gnail|gmai\.com|yaho\.com|yahooo\.com|hotmial|hotmail.co$|gmail.co$|yahoo.co$/
      errors.add_to_base("Did you mistype your email? Please double check your email and try again.")
      return false
    else
      return true
    end
  end
end