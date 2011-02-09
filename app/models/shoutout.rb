class Shoutout < ActiveRecord::Base
  named_scope :in_rotation, :conditions => ['rotation_start_date < ? and rotation_end_date > ?', Time.now.utc, Time.now.utc]
  
  has_attached_file :image1, 
                      :url  => "/dc/shoutouts/:id/image1.:extension", 
                      :path => ":rails_root/public/system/assets/dc/shoutouts/:id/image1.:extension",
                      :default_url => "/images/deal_default_image.png"
  
  def in_rotation?
    (self.rotation_start_date < Time.now.utc) and (self.rotation_end_date > Time.now.utc)
  end
end
