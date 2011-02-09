class Reminder < ActiveRecord::Base
  belongs_to :promotion

  REMINDER_THRESHOLD = 0.2
  
  validates_format_of :email, :with => /^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/, :on => :create, :message => "is invalid"
  
  def emailed!
    self.emailed = true
    self.save
  end
end