class Admin::EventsController < ApplicationController
  layout 'admin', :except => [:show]
  before_filter :admin_required

  # GET /events
  # GET /events.xml
  def index
    @events = Event.find(:all, :order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date > ? and active = ?', Time.now.utc, Time.now.utc, true], :order => 'updated_at DESC', :limit => 3)
    @side_promotions = []
    @side_promotions[0] = @event.side_promotion_1.to_i > 0 ? Promotion.find(@event.side_promotion_1.to_i) : Promotion.featured.first
    @side_promotions[1] = @event.side_promotion_2.to_i > 0 ? Promotion.find(@event.side_promotion_2.to_i) : Promotion.featured.first
    @side_promotions[2] = @event.side_promotion_3.to_i > 0 ? Promotion.find(@event.side_promotion_3.to_i) : Promotion.featured.first
    @google_tracking = "?utm_source=happyhourannouncement&utm_medium=email&utm_campaign=happyhour"
    
    respond_to do |format|
      format.html { render :action => "show"}
      format.xml  { render :xml => @event }
    end
  end

  def preview
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html { render :action => "preview", :layout => 'no_sidebar'}
      format.xml  { render :xml => @event }
    end
  end

  def sidebar_preview
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html { render :action => "sidebar_preview", :layout => 'no_sidebar'}
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and start_date > ? and active = ? and hidden = ?', (Time.now.utc + 3.days), (Time.now.utc - 14.days), true, false], :order => 'start_date DESC')

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @promotions = Promotion.find(:all, :conditions => ['start_date < ? and start_date > ? and active = ? and hidden = ?', (Time.now.utc + 3.days), (Time.now.utc - 14.days), true, false], :order => 'start_date DESC')
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.survey_question = params[:survey_question]

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(admin_event_path(@event)) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    @event.survey_question = params[:survey_question]

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(admin_event_path(@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(admin_events_url) }
      format.xml  { head :ok }
    end
  end
  
  def rsvp_list
    @event = Event.find(params[:id])
    
    @path = "dc/events/rsvp_exports/event_#{@event.id}_rsvps.xls"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    sheet1.row(0).push "First Name", "Last Name", "Email", "Survey Response"
    @event.attendees.each_with_index do |attendee,i|
      sheet1.row(i+1).push attendee.user.customer.first_name, attendee.user.customer.last_name, attendee.user.email, attendee.survey_question_value
    end

    format = Spreadsheet::Format.new :weight => :bold, :size => 18
    sheet1.row(0).default_format = format
    
    book.write "public/system/assets/" + @path
    
    render :action => 'rsvp_list'
    
  end
end
