class Attendee < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validates_presence_of :event_id, :on => :create, :message => "can't be blank"
  validates_presence_of :user_id, :on => :create, :message => "can't be blank"
  validates_uniqueness_of :user_id, :scope => :event_id, :on => :create, :message => "must be unique"
end
