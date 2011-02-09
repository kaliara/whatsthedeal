class Item < ActiveRecord::Base
  has_many :bids

  has_attached_file :image1, 
                      :styles => { :original => "315x222>" }, 
                      :url  => "/dc/items/:id/image1.:extension", 
                      :path => ":rails_root/public/system/assets/dc/items/:id/image1.:extension",
                      :default_url => "/images/deal_default_image.png"

  def high_bid
    Bid.find(:first, :conditions => {:item_id => self.id}, :order => 'amount DESC')
  end
  
  def high_bidder
    @bid = self.high_bid
    @bid.nil? ? 'No Bids' : (@bid.user.customer.has_name? ? @bid.user.customer.first_name : "Anonymous" )
  end
  
  def almost_over?
    (Time.zone.now - self.end_date).abs.seconds < 40.hours
  end
  
  def ended?
    Time.zone.now > self.end_date
  end
end
