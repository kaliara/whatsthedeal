class Credit < ActiveRecord::Base
  belongs_to :cart
  belongs_to :user
  belongs_to :promotion_code
  belongs_to :purchase
  
  named_scope :redeemable, :conditions => ['purchase_id IS NULL']
  named_scope :cartless, :conditions => ['cart_id IS NULL']
  
  validates_presence_of :promotion_code_id, :on => :create, :message => "cannot be empty"
  validates_presence_of :user_id, :on => :create, :message => "is blank, meaning you didn't register yet"
  
  before_create :valid_meets_restrictions?, :valid_unused_promotion_code?, :valid_redeemable?, :valid_promotion_code?, :valid_referral?
  
  def valid_meets_restrictions?
    return true unless self.promotion_code.restricted?
    
    Credit.find(:all, :conditions => ['user_id = ? and id > 0 and promotion_code_id > 3', self.user_id]).each do |c|
      if c.restricted?
        errors.add :promotion_code, 'Sorry, but this promo can only be used when you register'
        return false
      end
    end
    
    return true
  end
  
  def valid_redeemable?
    if self.promotion_code.redeemable?
      true
    else
      errors.add :promotion_code, 'Sorry, but this promo code is all used up'
      false
    end
  end
  
  def valid_promotion_code?
    if PromotionCode.exists?(self.promotion_code_id)
      true
    else
      errors.add :promotion_code, 'Sorry, but this is not a valid promo code'
      false
    end
  end
  
  def valid_unused_promotion_code?
    if [PromotionCode::REFERRAL_CREDIT, PromotionCode::DIFFERENCE_CREDIT, PromotionCode::COURTESY_CREDIT, PromotionCode::REFUND_CREDIT].include?(promotion_code_id) or Credit.find(:all, :conditions => [ "user_id = ? AND promotion_code_id = ?", self.user_id, self.promotion_code_id]).empty?
      true
    else
      errors.add :promotion_code, 'Hey now, you already used that promotion code'
      false
    end
  end
  
  def valid_referral?
    if self.user_id == self.referrer_user_id
      errors.add :referral, "Silly rabbit, you can't refer yourself. That would be a violation of the time warp continuum!"
      false
    else
      true
    end
  end

  def restricted?
    self.promotion_code.restricted?
  end
  
  def user_referral?
    !self.referrer_user_id.nil? and !User.find(self.referrer_user_id).staff?
  end
  
  def redeem!(purchase)
    self.purchase_id = purchase.id
    self.cart_id = nil

    if self.save!
      # generate referral credit for each (as long as its not the admin)
      #if User.exists?(self.referrer_user_id) and !User.find(self.referrer_user_id).admin? and User.find(self.referrer_user_id).customer?
      if self.user_referral?
        @referral_code = PromotionCode.find(PromotionCode::REFERRAL_CREDIT)
    
        @referral_credit = Credit.new
        @referral_credit.promotion_code = @referral_code
        @referral_credit.user_id = self.referrer_user_id
        @referral_credit.value = @referral_code.value.to_f
    
        # send notification if everything went ok
        if @referral_credit.save and @referral_credit.user.gets_referral_notification_email?
          Notifier.deliver_referral_notification(@referral_credit)
        end
        return true
      else
        errors.add :promotion_code, 'Sorry, we encountered an error. Please try again.'
        return false
      end
    end
  rescue Timeout::Error => e
  end
  
  def name
    [PromotionCode::REFERRAL_CREDIT, PromotionCode::DIFFERENCE_CREDIT, PromotionCode::COURTESY_CREDIT, PromotionCode::REFUND_CREDIT].include?(self.promotion_code_id) ? "WTD Credit" : self.promotion_code.name
  end
end