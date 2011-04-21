class Refund < ActiveRecord::Base
  belongs_to :credit
  belongs_to :purchase
  
  validates_presence_of :purchase_id, :on => :create, :message => "must be tied to the refund by seletecting a coupon to refund"
  
  def coupons
    Coupon.refunded.select{|c| c.purchase_id == self.purchase_id}
  end
end
