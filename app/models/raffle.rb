class Raffle < ActiveRecord::Base
  PREVIEW_PASSWORD = "special_preview"

  belongs_to :business
  has_many :entries
  
  named_scope :in_rotation, :conditions => ['rotation_start_date < ? and rotation_end_date > ? and hidden = ?', Time.now.utc, Time.now.utc, false]
  
  validates_inclusion_of :subscription_list_id, :in => 1..500, :on => :create, :message => "seems incorrect, make sure you get only the two-digit subscription list ID"

  has_attached_file :image1, 
                      :url  => "/dc/raffles/:id/image1.:extension", 
                      :path => ":rails_root/public/system/assets/dc/raffles/:id/image1.:extension",
                      :default_url => "/images/deal_default_image.png"

  def in_rotation?
    (self.rotation_start_date < Time.now.utc) and (self.rotation_end_date > Time.now.utc)
  end
end
