class Origin < ActiveRecord::Base
  ORIGIN_TYPES = [['Partner Tracking Code',1], ['WTD Referral Credit',2], ['User Referral Credit',3], ['WTD Campaign',4], ['Embedded Affiliate',5]]
  CPAS = {:intermark => 75, :lon => 110, :epicmg => 164}
  
  has_many :users
  has_many :subscribers
  has_many :purchases, :through => :users
  belongs_to :business
  
  def embedded?
    self.origin_type == 5
  end
  
  def subscribers(start_date=nil, end_date=nil)
    User.find(:all, :conditions => ['gets_daily_deal_email = ? and origin_id = ? and created_at >= ? and created_at < ?', true, self.id, start_date, end_date + 1.day])
  end
  
  def qualified_purchases(start_date=nil, end_date=nil)
    self.users.find(:all, :conditions => ['created_at >= ? and created_at < ?', start_date, end_date + 1.day]).collect{|user| user.purchases.find(:first, :order => 'created_at ASC') if (!user.purchases.empty? and ((user.purchases.find(:first, :order => 'created_at ASC').created_at - user.created_at).abs <= 7.days.seconds))}.delete_if{|i| i.nil?}
  end
  
  def purchases_total(start_date=nil, end_date=nil)
    self.qualified_purchases(start_date, end_date).collect{|qp| qp.deals_total.to_f}.sum
  end
  
  def purchases_profit(start_date=nil, end_date=nil)
    self.qualified_purchases(start_date, end_date).collect{|qp| qp.profit.to_f}.sum
  end
  
end