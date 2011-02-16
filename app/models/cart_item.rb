class CartItem < ActiveRecord::Base
  belongs_to :deal
  belongs_to :cart
  
  validates_length_of :quantity, :within => 1..100, :on => :save, :message => "must be at least one"
  validate :check_quantity
  attr_accessor :quantity_adding
  
  def check_quantity
    errors.add_to_base("You've got the max already in your cart for #{self.deal.name}. Please proceed to checkout by clicking the button below.") if self.quantity > self.deal.purchase_limit and !self.gift?
  end
  
  def valid_gift?
    !(self.gift_name.blank? or self.gift_email.blank? or self.gift_send_date.blank? or self.gift_from.blank? or (self.cart.user.nil? ? false : self.gift_name.gsub(/\s/,'').downcase == self.cart.user.customer.name.gsub(/\s/,'').downcase)) and (CartItem.find(:all, :conditions => ['deal_id = ? and cart_id = ? and gift = ? and gift_name = ? and id != ?', self.deal_id, self.cart_id, true, self.gift_name, self.id.to_i]).empty?)
  end
end
