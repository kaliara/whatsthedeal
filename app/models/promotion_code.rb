class PromotionCode < ActiveRecord::Base
  has_many :credits
  belongs_to :user

  validates_presence_of :user_id, :on => :save, :message => "can't be blank"
  validates_numericality_of :user_id, :greater_than => 0, :on => :save, :message => "must be greater than 0"
  
  REFERRAL_CREDIT   = 1
  DIFFERENCE_CREDIT = 2
  COURTESY_CREDIT   = 3

  def redeemable?
    self.active? and (self.credits.count < self.use_limit)
  end
  
  def gifted_credit?
    self.name.include? "WTD Credit"
  end
  
  def unlist!
    self.listed = false
    self.save
  end
  
  def bad_referral?(new_user_id)
    @old_user = User.find(self.user_id)
    @new_user = User.find(new_user_id)
    
    unless @old_user.nil? or @old_user.customer.nil? or @new_user.nil? or @new_user.customer.nil? or @old_user.customer.last_name.downcase != @new_user.customer.last_name.downcase
      @user_review = UserReview.new
      @user_review.user = self.user
      @user_review.referred_user_id = new_user_id
      @user_review.save
      return true
    end
  
    return false
  end
end