class UserReview < ActiveRecord::Base
  belongs_to :user

  after_create :send_notification
  
  def send_notification
    Notifier.deliver_user_review_added(self)
  rescue Timeout::Error => e
  end
  
  def referred_user
    User.find(self.referred_user_id)
  end
end
