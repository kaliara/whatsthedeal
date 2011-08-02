class Admin::NewslettersController < ApplicationController
  layout 'admin', :except => [:generate]
  before_filter :admin_required
  
  def setup
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and start_date > ? and active = ? and hidden = ?', (Time.now.utc + 36.hours), (Time.now.utc - 14.days), true, false], :order => 'start_date DESC')
    @side_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and id != ?', (Time.now.utc + 20.hours), (Time.now.utc + 20.hours), true, false, 0], :order => 'end_date ASC')
    @events = Event.all.reverse
    @shoutouts = Shoutout.all.reverse
  end

  def generate
    @deal_region = params[:deal_region].to_i
    @promotion = Promotion.find(params[:promotion_id])
    @alt_city_promotion = params[:alt_city_promotion].to_i > 0 ? Promotion.find(params[:alt_city_promotion]) : nil
    @side_promotions = []
    @side_promotions[0] = Promotion.find(params[:side_promotion_1]) if params[:side_promotion_1].to_i > 0
    @side_promotions[1] = Promotion.find(params[:side_promotion_2]) if params[:side_promotion_2].to_i > 0
    @side_promotions[2] = Promotion.find(params[:side_promotion_3]) if params[:side_promotion_3].to_i > 0
    @event1 = Event.find(params[:event1_id]) if params[:event1_id].to_i > 0
    @event2 = Event.find(params[:event2_id]) if params[:event2_id].to_i > 0
    @shoutout1 = Shoutout.find(params[:shoutout1_id]) if params[:shoutout1_id].to_i > 0
    @shoutout2 = Shoutout.find(params[:shoutout2_id]) if params[:shoutout2_id].to_i > 0
    @google_tracking = "?utm_source=newsletter&utm_medium=email#{"_nova" if @deal_region == 2}&utm_campaign=dailydeal"
  end

end