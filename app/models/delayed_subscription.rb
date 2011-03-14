class DelayedSubscription < ActiveRecord::Base
  validates_presence_of :list, :on => :create, :message => "can't be blank"
  validates_presence_of :email, :on => :create, :message => "can't be blank"

  def subscribed!
    self.subscribed = true
    self.save
  end
end
