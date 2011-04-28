class KgbCoupon < ActiveRecord::Base
  validates_numericality_of :transactions_deal_id, :on => :create, :message => "must be a number"
  validates_uniqueness_of :transactions_transaction_id, :on => :create, :message => "must be unique"
  
  def name
    self.deal.coupon_name
  end

  def description
    self.deal.coupon_description
  end
  
  def deal
    Deal.find(:all, :conditions => {:kgb_deal_id => self.transactions_deal_id}).first
  end

  def coupon_code
    nil
  end

  def confirmation_code
    self.transactions_transaction_id
  end

  def expiration
    self.deal.coupon_expiration
  end
  
  def created_at
    self.transactions_timestamp
  end

  def expired?
    self.deal.coupon_expiration + 1.day - DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 23, 59, 59) < 0
  end

  def recipient
    self.users_first_name + " " + self.users_last_name
  end
  
  def biz_used!
    self.biz_used = true
    self.save
  end

  def gifted_credit?
    false
  end

  def refundable?
    false
  end

  def stolen?(current_user)
    false
  end

  def shippable?
    false
  end

  def active?
    true
  end

  def available_tomorrow?
    true
  end

  def kgb_coupon?
    true
  end
end