class Content < ActiveRecord::Base
  ROTATION_CATEGORIES = { 'partner_shoutout' => 1, 'event' => 2 }
  
  validates_format_of :name, :with => /^[\w\d\_]+$/, :on => :create, :message => "can contain only letters, numbers and underscores ('_')"
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :value, :on => :create, :message => "can't be blank"

  default_scope :order => 'name ASC'
end