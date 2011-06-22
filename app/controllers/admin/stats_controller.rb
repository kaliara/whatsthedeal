class Admin::StatsController < ApplicationController
  layout 'admin'
  before_filter :admin_required
  
  def top_purchasers
    @users = {}
    User.all.each do |user|
      @users[user.id] = user.coupons.collect{|c| c.deal.promotion.id}.uniq.size
    end
    @top_peeps = @users.sort{|a,b| b[1]<=>a[1]}
  end

  def promotion_zipcodes
    @promotions = Promotion.find(:all, :order => 'id DESC')
  end
  
  def monthly_credit
    @start_date = Date.civil(2009, 8, 1)
    @date = @start_date
    @credits = []
    while @date < Date.today
      @credits << Credit.find(:all, :conditions => ['updated_at >= ? and updated_at < ? and user_id is not null and purchase_id is not null and promotion_code_id != 2', @date, @date + 1.month]).collect{|c| c.value}.sum
      @date = @date + 1.month
    end
    
    @outstanding_credit = Credit.find(:all, :conditions => ['user_id is not null and promotion_code_id != 2 and purchase_id is null']).collect{|c| c.value}.sum
  end
  
  def zipcode_counts
    @zipcodes = Customer.find_by_sql('select zipcode, count(*) from customers where zipcode is not null and zipcode != "" group by zipcode order by count(*) DESC').collect{|z| z.zipcode}
  end
end
