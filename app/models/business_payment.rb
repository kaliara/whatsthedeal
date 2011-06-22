class BusinessPayment < ActiveRecord::Base
  belongs_to :business
  belongs_to :promotion
  
  PAYMENT1_PERCENTAGE = 0.9
  
  def business_id
    self.promotion.business.id
  end
  
  def payment1_estimate
    self.promotion.business_profit * PAYMENT1_PERCENTAGE
  end
  
  def payment2_estimate
    self.payment1_amount > 0 ? (self.promotion.business_profit - self.payment1_amount) : 0
  end
end