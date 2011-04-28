class KgbCoupon < ActiveRecord::Base
  belongs_to :deal, :class_name => "Deal", :foreign_key => "kgb_deal_id"

  validates_numericality_of :transactions_deal_id, :on => :create, :message => "must be a number"
  validates_uniqueness_of :transactions_transaction_id, :on => :create, :message => "must be unique"
  
  def name
    self.deals_title
  end

  def description
    self.deals_title
  end

  def coupon_code
    return "KGB1234"
  end

  def confirmation_code
    self.transactions_transaction_id
  end

  def expiration
    self.deals_coupon_expires
  end

  def expired?
    self.deals_coupon_expires + 1.day - DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 23, 59, 59) < 0
  end

  def recipient
    self.users_first_name + self.users_last_name
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
end