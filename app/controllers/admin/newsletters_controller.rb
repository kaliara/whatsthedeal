class Admin::NewslettersController < ApplicationController
  layout 'admin', :except => [:generate]
  before_filter :staff_required 
  
  def setup
    # I HATE DOING THIS!!!
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    
    @promotions = Promotion.all.reverse
    @side_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ? and hidden = ? and id != ?', (Time.now.utc + 20.hours), (Time.now.utc + 20.hours), true, false, 0], :order => 'end_date ASC')
    @events = Event.all.reverse
    @shoutouts = Shoutout.all.reverse
  end

  def generate
    @promotion = Promotion.find(params[:promotion_id])
    @side_promotions = Promotion.find([params[:side_promotion_1], params[:side_promotion_2], params[:side_promotion_3]])
    @event = Event.find(params[:event_id]) if params[:event_id].to_i > 0
    @shoutout = Shoutout.find(params[:shoutout_id]) if params[:shoutout_id].to_i > 0
    @google_tracking = "?utm_source=newsletter&utm_medium=email&utm_campaign=dailydeal"
  end

end