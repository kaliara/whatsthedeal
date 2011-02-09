class BusinessPayment < ActiveRecord::Base
  belongs_to :business
  belongs_to :promotion
  
  def business_id
    self.promotion.business.id
  end
end
