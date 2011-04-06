class Event < ActiveRecord::Base
  PREVIEW_PASSWORD = "special_preview"

  belongs_to :business
  has_many :attendees
  
  named_scope :in_rotation, :conditions => ['rotation_start_date < ? and rotation_end_date > ? and hidden = ?', Time.now.utc, Time.now.utc, false]
  
  validates_inclusion_of :subscription_list_id, :in => 1..500, :on => :create, :message => "seems incorrect, make sure you get only the two-digit subscription list ID"

  has_attached_file :image1, 
                      :url  => "/dc/events/:id/image1.:extension", 
                      :path => ":rails_root/public/system/assets/dc/events/:id/image1.:extension",
                      :default_url => "/images/deal_default_image.png"
  
  has_attached_file :image2, 
                      :url  => "/dc/events/:id/image2.:extension", 
                      :path => ":rails_root/public/system/assets/dc/events/:id/image2.:extension",
                      :default_url => "/images/deal_default_image.png"
  
  has_attached_file :image3, 
                      :url  => "/dc/events/:id/image3.:extension", 
                      :path => ":rails_root/public/system/assets/dc/events/:id/image3.:extension",
                      :default_url => "/images/deal_default_image.png"
  
  def started_rotation?
    (self.rotation_start_date < Time.now.utc)
  end
  
  def in_rotation?
    self.started_rotation? and (self.rotation_end_date > Time.now.utc)
  end
  
  def rsvps_closed?
    !(self.started_rotation? and (self.end_date > Time.now.utc))
  end
  
  def full_attendance?
    self.attendees_max > 0 and self.attendees.size >= self.attendees_max
  end
end