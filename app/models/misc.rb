class Misc < ActiveRecord::Base
  validates_format_of :key, :with => /^[\w\d\_]+$/, :on => :create, :message => "can contain only letters, numbers and underscores ('_')"
  validates_presence_of :key, :on => :create, :message => "can't be blank"
  validates_presence_of :value, :on => :create, :message => "can't be blank"

  # default_scope :order => 'key ASC'

  def self.value(key, default=nil)
    return Misc.exists?(:key => key) ? Misc.find_by_key(key).value : default
  end
end