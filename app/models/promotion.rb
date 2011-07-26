class Promotion < ActiveRecord::Base
  has_many :deals
  has_many :coupons, :through => :deals
  belongs_to :business
  
  named_scope :featured, :conditions => ['dc_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ?)', true, Time.now.utc, Time.now.utc, true, false], :order => 'dc_featured DESC, start_date DESC', :limit => 1
  named_scope :dc_featured, :conditions => ['dc_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ? and city_id = ?)', true, Time.now.utc, Time.now.utc, true, false, 0], :order => 'dc_featured DESC, start_date DESC', :limit => 1
  named_scope :nova_featured, :conditions => ['nova_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ? and city_id = ?)', true, Time.now.utc, Time.now.utc, true, false, 2], :order => 'nova_featured DESC, start_date DESC', :limit => 1
  # named_scope :somd_featured, :conditions => ['somd_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ? and city_id = ?)', true, Time.now.utc, Time.now.utc, true, false, 3], :order => 'submd_featured DESC, start_date DESC', :limit => 1
  named_scope :washingtonian_featured, :conditions => ['washingtonian_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ?)', true, Time.now.utc, Time.now.utc, true, false], :order => 'washingtonian_featured DESC, start_date DESC', :limit => 1
  named_scope :halfpricedc_featured, :conditions => ['halfpricedc_featured = ? or (start_date < ? and end_date > ? and active = ? and hidden = ?)', true, Time.now.utc, Time.now.utc, true, false], :order => 'halfpricedc_featured DESC, start_date DESC', :limit => 1
  named_scope :dc,    :conditions => ['(city_id = ? or city_id = 0) and start_date < ? and end_date > ? and active = ? and hidden = ?', 1, Time.now.utc, Time.now.utc, true, false], :order  => 'nova_featured DESC, city_id DESC, start_date DESC'
  named_scope :nova,  :conditions => ['(city_id = ? or city_id = 0) and start_date < ? and end_date > ? and active = ? and hidden = ?', 2, Time.now.utc, Time.now.utc, true, false], :order  => 'nova_featured DESC, city_id DESC, start_date DESC'
  named_scope :submd, :conditions => ['(city_id = ? or city_id = 0) and start_date < ? and end_date > ? and active = ? and hidden = ?', 3, Time.now.utc, Time.now.utc, true, false], :order  => 'submd_featured DESC, city_id DESC, start_date DESC'
  named_scope :sidebar, lambda { |excluded, city_id| {:conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and id not in (?)', Time.now.utc, Time.now.utc, true, false, excluded.nil? ? 0 : excluded.join(',')], :order => "#{['','dc_', 'nova_'][city_id.nil? ? 0 : city_id.to_i]}position ASC", :limit => 4}}

  has_attached_file :image1, 
                      :styles => { :original => "315x222>" }, 
                      :url  => "/dc/promotions/:id/image1.:extension", 
                      :path => ":rails_root/public/system/assets/dc/promotions/:id/image1.:extension",
                      :default_url => "/images/deal_default_image.png"

  has_attached_file :image2, 
                      :styles => { :original => "600x900>" }, 
                      :url  => "/dc/promotions/:id/image2.:extension", 
                      :path => ":rails_root/public/system/assets/dc/promotions/:id/image2.:extension",
                      :default_url => "/images/deal_default_image.png"

  has_attached_file :ad_image1, 
                      :styles => { :original => "140x140#" }, 
                      :url  => "/dc/promotions/:id/ad_image.:extension", 
                      :path => ":rails_root/public/system/assets/dc/promotions/:id/ad_image.:extension",
                      :default_url => "/images/deal_default_image_140.png"

  has_attached_file :map_replacement_image, 
                      :styles => { :original => "265x265>" }, 
                      :url  => "/dc/promotions/:id/map_replacement_image.:extension", 
                      :path => ":rails_root/public/system/assets/dc/promotions/:id/map_replacement_image.:extension"

  validates_attachment_presence :image1
  validates_attachment_size :image1, :less_than => 2.megabytes
  validates_uniqueness_of :slug, :on => :save, :message => "(url name) is already in use, try another one"
  validates_presence_of :slug, :on => :save, :message => "must be provided"
  
  after_save :update_business_payments

  PREVIEW_PASSWORD = 'special_preview'
  BUY_AS_GIFT_LABEL = 'Buy As Gift'
  BUYING_CREDIT_PROMOTION = 266
  PROMOTION_MAP_DEFAULT_LAT = 38.897275
  PROMOTION_MAP_DEFAULT_LNG = -77.036594
  TRANSITION_TO_NEW_COUPON_STYLE = 575
  CITIES = [['All Cities',0], ['Washington DC',1], ['Northern Virginia',2], ['Southern Maryland',3]]
  
  def active?
    self.active == true and self.start_date < Time.now.utc and self.end_date > Time.now.utc
  end
  
  def featured?
    self.dc_featured?
  end
  
  def dc_featured?
    Promotion.featured.empty? ? false : self.id == Promotion.featured.first.id
  end
  
  def early_bird?
    self.deals.each do |d|
      return true if d.early_bird?
    end
    return false
  end
  
  def kgb_linked?
    return !self.deals.delete_if{|d| d.kgb_deal_id.to_i > 1}.empty?
  end
  
  def updated_coupon_style?
    self.id >= Promotion::TRANSITION_TO_NEW_COUPON_STYLE
  end
  
  def auto_activate_coupons?
    self.auto_activate_coupons == true and self.quota_met? and (self.start_date < 1.day.ago)
  end

  def featured_deal
    self.deals.featured.first || self.deals.first
  end
  
  def purchases(partner_id=nil,include_kgb=false)
    if self.id == 230
      Promotion.find(231,232,233,234,235,236,237).collect{|p| p.purchases}.sum
    elsif self.id == 216
      Promotion.find(217,218,219,220,221).collect{|p| p.purchases}.sum
    elsif partner_id.nil? and include_kgb
      self.deals.collect{|d| d.total_coupons}.to_a.sum
    elsif partner_id.nil?
      self.deals.collect{|d| d.coupons.count}.to_a.sum
    else
      self.deals.collect{|d| d.coupons.select{|c| c.purchase.partner_id == partner_id}.size}.to_a.sum
    end
  end
  
  def buyers_needed 
    [self.quota - self.purchases, 0].max
  end
  
  def quota_met?
    buyers_needed == 0
  end
  
  def sold_out?
    self.deals.each do |deal|
      return false unless deal.sold_out?
    end
    
    return true
  end
  
  def near_sellout?
    self.deals.each do |deal|
      return true if deal.near_sellout?
    end
    
    return false
  end
  
  def almost_over?
    (Time.zone.now - self.end_date).abs.seconds < 40.hours
  end
  
  def ended?
    Time.zone.now > self.end_date
  end
  
  def revenue(partner_id=nil)
    if partner_id.nil?
      self.deals.collect{|d| d.price * d.coupons.count}.sum
    else
      self.deals.collect{|d| d.price * d.coupons.select{|c| c.purchase.partner_id == partner_id}.size}.sum
    end
  end
  
  def initial_revenue(partner_id=nil)
    self.revenue + self.refund_amount
  end
  
  def initial_purchases
    self.purchases + Coupon.refunded.select{|c| c.deal.promotion_id == self.id}.size
  end
  
  def refund_amount
    Coupon.refunded.select{|c| c.deal.promotion_id == self.id}.collect{|c| c.deal.price}.sum
  end
  
  def profit(partner_id=nil)
    if partner_id.nil?
      self.deals.collect{|d| d.profit * d.coupons.count}.sum
    else
      self.deals.collect{|d| d.profit * d.coupons.select{|c| c.purchase.partner_id == partner_id}.size}.sum
    end
  end
  
  def credit_used(partner_id=nil)
    if partner_id.nil?
      self.deals.collect{|deal| deal.coupons.collect{|c| c.purchase}.uniq.collect{|p| p.coupons.select{|c| c.deal_id == deal.id}.size * p.credit_per_deal}.sum}.sum
    else
      self.deals.collect{|deal| deal.coupons.select{|c| c.purchase.partner_id == partner_id}.collect{|c| c.purchase}.uniq.collect{|p| p.coupons.select{|c| c.deal_id == deal.id}.size * p.credit_per_deal}.sum}.sum
    end
  end
  
  def early_bird_losses
    @early_bird_coupons = Coupon.find(:all, :conditions => {:deal_id => self.deals}, :order => 'created_at ASC', :limit => self.quota)
    return @early_bird_coupons.collect{|coupon| coupon.early_bird? ? coupon.deal.early_bird_discount : 0}.sum.to_f
  end
  
  def business_profit(include_kgb=false)
    if include_kgb
      self.deals.collect{|d| d.business_profit * d.total_coupons}.sum
    else
      self.deals.collect{|d| d.business_profit * d.coupons.count}.sum
    end
  end
  
  def update_business_payments
    BusinessPayment.find(:all, :conditions => {:promotion_id => self.id}).each do |bp|
      bp.business_id = self.business_id
      bp.save
    end
  end
  
  def self.arlnow
    Promotion.find(Misc.value('arlnow', Promotion.featured.first.id).to_i)
  end
end
