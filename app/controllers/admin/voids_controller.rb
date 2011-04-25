class Admin::VoidsController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => [:processing]

  # GET /voids
  # GET /voids.xml
  def index
    @now = DateTime.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, Time.zone.now.hour, Time.zone.now.min, Time.zone.now.sec)
    @start_date = params[:start_date].nil? ? DateTime.new(@now.year, @now.month, 1, 4, 0) : DateTime.parse(params[:start_date] + " 04:00:00")
    @end_date   = params[:end_date].nil? ? DateTime.new(@now.year, @now.month, -1, 4, 0) : DateTime.parse(params[:end_date] + " 04:00:00")
    
    @voids = Void.find(:all, :conditions => ['created_at >= ? and created_at < ?', @start_date, @end_date + 1.day])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @voids }
    end
  end

  # GET /voids/1
  # GET /voids/1.xml
  def show
    @void = Void.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => "show"}
      format.xml  { render :xml => @void }
    end
  end

  def processing
    @void = Void.find(params[:id])
    @void.processed = true
    @void.save
    
    redirect_to :back
  end
end