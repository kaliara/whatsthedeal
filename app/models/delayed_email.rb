class DelayedEmail < ActiveRecord::Base
  validates_presence_of :template, :on => :create, :message => "can't be blank"
  validates_presence_of :delay_until, :on => :create, :message => "can't be blank"
  validates_presence_of :user_id, :on => :create, :message => "can't be blank"
  
  def emailed!
    self.emailed = true
    self.save
  end
end
