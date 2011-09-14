class Coupon < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user
  belongs_to :purchase
  
  default_scope :conditions => {:deleted => false, :refunded => false}, :order => 'updated_at DESC'
  
  named_scope :unused,   :conditions => {:used => false, :gift => false}
  named_scope :used,     :conditions => {:used => true, :gift => false}
  named_scope :expired,  :conditions => {:gift => false}
  named_scope :gifts,    :conditions => {:gift => true}
  named_scope :active,   :conditions => {:active => true, :printed => false}
  named_scope :printed,  :conditions => {:printed => true}
  named_scope :inactive, :conditions => {:active => false}  
  
  before_save :valid_gift?
  after_create :generate_confirmation_code, :generate_gift_access_token
  
  def name
    self.deal.coupon_name
  end

  def description
    self.deal.coupon_description
  end
  
  def coupon_code
    return "" unless (self.deal.has_coupon_code? or self.deal.pregenerated_codes?)
    
    if self.deal.pregenerated_codes?
      Misc.value("deal_#{self.deal.id}_codes","CODEnotFOUND").split(/<br\s?\/?>|\W/i).delete_if{|x| x.blank?}[self.number - 1].to_s
    elsif self.deal.coupon_code_delta.to_i > 0
      self.deal.coupon_code_prefix + (self.deal.coupon_code_start + (self.deal.coupon_code_delta * self.number)).to_s(self.deal.coupon_code_number_base).upcase
    else
      self.deal.coupon_code_prefix
    end
  end
  
  def new_coupon_number
    @last = Coupon.find(:first, :conditions => {:deal_id => deal.id}, :order => 'number DESC')
    @last.nil? ? 1 : @last.number + 1
  end
  
  def generate_confirmation_code
    self.confirmation_code = self.id.to_s(16).upcase.reverse + "-" + self.user.id.to_s
    self.save
  end
  
  def generate_gift_access_token
    if self.gift? and self.valid_gift?
      self.gift_access_token = Digest::MD5.hexdigest(self.gift_name.reverse + self.id.to_s)
      self.save
    end
  end
  
  def expiration
    self.deal.coupon_expiration
  end
  
  def expired?
    self.deal.coupon_expiration + 1.day - DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 23, 59, 59) < 0
  end
  
  def recipient
    self.gift? ? self.gift_name : self.user.customer.name
  end
  
  def gifted_credit?
    self.gifted_promotion_code.to_i > 0
  end
  
  def activate!
    self.active = true
    self.save
  end
  
  def printed!
    self.printed = true
    self.save
  end
  
  def emailed!
    self.emailed = true
    self.save
  end
  
  def reminded!
    self.reminded = true
    self.save
  end
  
  def biz_use!
    self.biz_used = true
    self.save
  end
  
  def delete!
    self.deleted = true
    self.save
  end
  
  def stolen?(current_user)
    current_user.nil? ? true : self.user.id != current_user.id
  end
  
  def shippable?
    self.deal.shippable?
  end
  
  def available_tomorrow?
    self.deal.promotion.quota_met?
  end
  
  def valid_gift?
    return true unless self.gift?
    
    !(self.gift_name.blank? or self.gift_name.gsub(/\s/,'').downcase == self.user.customer.name.gsub(/\s/,'').downcase or self.gift_email.blank? or self.gift_from.blank? or self.gift_send_date.blank? or Coupon.find(:all, :conditions => {:user_id => self.user.id, :deal_id => self.deal_id, :gift_name => self.gift_name}).size > self.deal.purchase_limit)
  end
  
  def self.deleted(limit=nil, offset=nil)
    Coupon.with_exclusive_scope { Coupon.find(:all, :conditions => {:deleted => true}, :limit => limit, :offset => offset) }
  end

  def self.refunded(limit=nil, offset=nil)
    Coupon.with_exclusive_scope { Coupon.find(:all, :conditions => {:refunded => true}, :limit => limit, :offset => offset) }
  end
  
  def kgb_coupon?
    false
  end
  
  def self.sample(deal_id, redeemed=false, gift=false)
    @coupon = Coupon.new
    @coupon.deal_id = deal_id
    @coupon.number = 1
    @coupon.confirmation_code = "ABCD-1234"
    @coupon.user = User.find(1)
    @coupon.active = true
    @coupon.emailed = true
    @coupon.used = redeemed
    @coupon.gift = gift
    @coupon.gift_name = "Matthew Burnett"
    
    return @coupon
  end
  
end