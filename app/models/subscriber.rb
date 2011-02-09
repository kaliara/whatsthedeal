class Subscriber < ActiveRecord::Base
  belongs_to :origin
  
  validates_uniqueness_of :email, :on => :save, :message => "must be unique"
end
