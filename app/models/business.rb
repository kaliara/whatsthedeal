class Business < ActiveRecord::Base
  belongs_to :user
  has_many :promotions
  has_many :origins
  has_many :events
  
  PROCESSING_FEE = 0.05
  INTERMARK = 75
  LOCAL_OFFER_LOUNGE = 110
  
  def has_address?
    !(self.street1.blank? or self.city.blank? or self.state.blank?)
  end

  def has_deals?
    !self.promotions.empty?
  end
  
  def has_affiliate_tracking?
    !self.origins.empty?
  end
  
  def has_late_business_payment?
    late = false
    @biz_payments = BusinessPayment.find(:all, :conditions => {:paid => false, :payment2_paid => false, :business_id => self.id})
    @biz_payments.each do |bp|
      late = true if bp.promotion.end_date <= 45.days.ago
    end
    return late
  end

end
