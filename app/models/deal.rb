class Deal < ActiveRecord::Base
  belongs_to :promotion
  belongs_to :business
  has_many :cart_items
  has_many :coupons
  
  named_scope :featured, :conditions => ['featured = ? and active = ?', true, true]
  named_scope :active,   :conditions => ['active = ?', true]
    
  validates_presence_of :name, :on => :save, :message => "can't be blank"
  validates_uniqueness_of :code, :on => :create, :message => "must be unique"
  validates_numericality_of :coupon_code_delta, :only_integer => true, :on => :save, :message => "must be a whole number"
  
  def purchase_limit_remaining(cart,gift_name=nil)
    @existing_cart_item = cart.cart_items.find(:first, :conditions => {:deal_id => self.id, :gift_name => gift_name})
    @existing_total_items = (@existing_cart_item.nil? ? 0 : @existing_cart_item.quantity.to_i) + (cart.user.nil? ? 0 : Coupon.find(:all, :conditions => {:user_id => cart.user.id, :deal_id => self.id, :gift_name => gift_name}).size)
    if @existing_total_items > 0
      [self.inventory_remaining, self.purchase_limit].min - @existing_total_items
    else
      [self.inventory_remaining, self.purchase_limit].min
    end
  end
  
  def dynamic_purchase_limit(cart,gift_name=nil)
    @existing_total_items = cart.user.nil? ? 0 : Coupon.find(:all, :conditions => {:user_id => cart.user.id, :deal_id => self.id, :gift_name => gift_name}).size
    [self.inventory_remaining, self.purchase_limit].min - @existing_total_items.to_i
  end
  
  def inventory_remaining
    return 9999 if self.inventory == 0
    self.inventory - self.coupons.count
  end
  
  def sold_out?
    self.inventory_remaining <= 0
  end
  
  def near_sellout?
    self.inventory_remaining <= (self.inventory * Reminder::REMINDER_THRESHOLD)
  end
  
  def early_bird?
    self.early_bird_discount > 0 and !self.promotion.quota_met?
  end
  
  def adjusted_price
    self.price - (self.early_bird? ? self.early_bird_discount : 0)
  end
  
  def savings
    (1 - self.adjusted_price.to_f / self.value.to_f) * 100
  end
  
  def revenue
    (self.price * self.coupons.count).to_f
  end
  
  def profit
    self.price * (self.promotion.profit_percentage.to_f / 100.00)
  end
  
  def business_profit
    self.price - self.profit
  end
  
  def credit_used 
    self.coupons.collect{|c| c.purchase}.uniq.collect{|p| p.coupons.delete_if{|c| c.deal_id != self.id}.size * p.credit_per_deal}.sum
  end
  
  def total_coupons
    self.coupons.count + self.kgb_coupons.count
  end
  
  def kgb_coupons
    KgbCoupon.find(:all, :conditions => {:transactions_deal_id => self.kgb_deal_id})
  end
end
