class Purchase < ActiveRecord::Base
  include ActiveMerchant::Utils

  has_many :coupons
  has_many :credits
  belongs_to :user
  has_one :payment_profile

  accepts_nested_attributes_for :payment_profile, :allow_destroy => false, :reject_if => proc { |obj| obj.blank? }
  
  before_create :process, :if => Proc.new { |p| p.total > 0 }
  default_scope :order => 'created_at DESC'
  
  attr_accessor :card_number, :card_verification, :customer_email, :description, :customer_ip

  # cim
  def process
    @gateway = get_payment_gateway
    response = @gateway.create_customer_profile_transaction({:transaction => {
                                                                :type => :auth_only,
                                                                :amount => total,
                                                                :customer_profile_id => self.user.customer_cim_id,
                                                                :customer_payment_profile_id => self.payment_profile.payment_cim_id,
                                                                :order => {
                                                                  :invoice_number => invoice_number,
                                                                  :description => description
                                                                }}
                                                            })
    puts "xxxxxxxxxxxxxxxxxx"
    puts response.to_yaml
    puts "yyyyyyyyyyyyyyyyyy"
    
    if response.success?
      return true
    else
      errors.add_to_base "#{response.params['direct_response']['message']}" unless (response.params.empty? or response.params['direct_response'].blank?)
      return false
    end
    
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end

  def partner_id
    user.partner_id
  end

  def profit
    self.coupons.collect{|coupon| (coupon.deal.price * (coupon.deal.promotion.profit_percentage.to_f / 100)) - (coupon.early_bird? ? coupon.deal.early_bird_discount : 0)}.sum
  end
  
  def early_bird_losses
    self.coupons.collect{|coupon| coupon.early_bird? ? coupon.deal.early_bird_discount : 0}.sum
  end
  
  def fees
    self.total * Business::PROCESSING_FEE
  end
  
  def credit_per_deal
    credit = (self.deals_total - self.total) / self.coupons.size.to_f
    credit.nan? ? 0 : credit
  end
  
  def price_in_cents
    (self.total*100).round
  end

  def build_coupons(cart)
    cart.cart_items.each do |cart_item|
      @alphabet = %W(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
      for i in 1..cart_item.quantity
        @coupon = Coupon.new
        @coupon.purchase_id       = self.id
        @coupon.user_id           = cart.user.id
        @coupon.deal_id           = cart_item.deal.id
        @coupon.name              = cart_item.deal.coupon_name + (cart_item.quantity > 1 ? " (#{@alphabet[i-1]})" : "")
        @coupon.description       = cart_item.deal.coupon_description
        @coupon.expiration        = cart_item.deal.coupon_expiration
        @coupon.number            = Coupon.find(:all, :conditions => {:deal_id => cart_item.deal.id}).size + 1
        @coupon.early_bird        = cart_item.deal.early_bird?
        if cart_item.gift?
          @coupon.gift              = cart_item.gift?
          @coupon.gift_from         = cart_item.gift_from
          @coupon.gift_name         = cart_item.gift_name
          @coupon.gift_email        = cart_item.gift_email
          @coupon.gift_message      = cart_item.gift_message
          @coupon.gift_send_date    = cart_item.gift_send_date
        end
        @coupon.active            = cart_item.deal.promotion.auto_activate_coupons? 
        @coupon.emailed           = cart_item.deal.promotion.auto_activate_coupons? unless cart_item.gift?

        if cart_item.deal.promotion.id == Promotion::BUYING_CREDIT_PROMOTION
          @promotion_code = PromotionCode.new
          @promotion_code.value = @coupon.deal.value
          @promotion_code.name = "#{@coupon.deal.coupon_name} from #{@coupon.user.customer.has_name? ? @coupon.user.customer.name : 'a friend'}"
          @promotion_code.listed = false
          @promotion_code.active = true
          @promotion_code.use_limit = 1
          @promotion_code.restricted = false
          @promotion_code.user_id = 1518
          @promotion_code.save
          
          # tie to coupon
          @coupon.gifted_promotion_code = @promotion_code.id
        end
        
        @coupon.save
        
        # generate gift code
        unless @promotion_code.nil?
          @promotion_code.code = "GC" + @promotion_code.id.to_s(16).upcase + @coupon.id.to_s(16).reverse.upcase
          @promotion_code.save
        end
      end
    end
  end
    
  def send_purchase_confirmation
    if self.partner_id.to_i == 1
      Notifier.deliver_sloopy_purchase_confirmation(self.user, self)
    else
      Notifier.deliver_purchase_confirmation(self.user, self)
    end
  rescue Timeout::Error => e
    return false
  end
  
end