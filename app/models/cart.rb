class Cart < ActiveRecord::Base
  has_many :cart_items
  has_many :credits
  belongs_to :user
  
  def deals_total
    self.cart_items.collect{|c| c.deal.adjusted_price.to_f * c.quantity}.to_a.sum
  end
  
  def true_credits_total
    self.credits.collect{|c| c.value.to_f}.to_a.sum
  end
  
  def credits_total
    @credit_amount = self.true_credits_total
    @credit_amount > deals_total ? deals_total : @credit_amount
  end
  
  def total
    @calculated_total = self.cart_items.collect{|c| c.deal.adjusted_price.to_f * c.quantity}.to_a.sum - self.credits.collect{|c| c.value.to_f}.to_a.sum
    @calculated_total < 0 ? 0 : @calculated_total
  end
  
  def empty?
    self.cart_items.empty?
  end
  
  def empty!
    self.cart_items.each do |cart_item|
      cart_item.destroy
    end
  end
  
  def has_credit_restricted_promotion?
    @restricted_promotion = false
    self.cart_items.each do |cart_item|
      @restricted_promotion = true if cart_item.deal.promotion.credit_restriction?
    end
    @restricted_promotion
  end
  
  def remove_soldout_deals?
    removed_deals = false
    
    self.cart_items.each do |cart_item|
      if cart_item.deal.sold_out?
        cart_item.destroy
        removed_deals = true
      end
    end
    
    self.save if removed_deals
    return removed_deals
  end
  
  def remove_invalid_gifts?
    removed_invalid_gift = false
    
    self.cart_items.each do |cart_item|
      if cart_item.gift? and !cart_item.valid_gift?
        cart_item.destroy
        removed_invalid_gift = true
      end
    end
    
    self.save if removed_invalid_gift
    return removed_invalid_gift
  end

  def shippable_item?
    self.cart_items.each do |cart_item|
      return true if cart_item.deal.shippable?
    end
    return false
  end
  
  def reconcile_credit
    @credit_value = self.credits.collect{|c| c.value.to_f}.to_a.sum
    @difference = @credit_value - self.deals_total
    if @difference > 0
      @credit = Credit.new
      @credit.promotion_code_id = PromotionCode::DIFFERENCE_CREDIT
      @credit.value = @difference
      @credit.user_id = self.user.id
      @credit.save
    end
  end
end