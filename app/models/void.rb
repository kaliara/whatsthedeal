class Void < ActiveRecord::Base
  belongs_to :purchase
  
  validates_presence_of :purchase_id, :on => :create, :message => "must associated with this void."
  
  def purchase
    Purchase.exists?(self.purchase_id) ? Purchase.find(self.purchase_id) : Purchase.deleted.select{|p| p.id == self.purchase_id}.first
  end
  
  def coupons
    Coupon.deleted.select{|c| c.purchase_id == self.purchase_id}
  end
end
