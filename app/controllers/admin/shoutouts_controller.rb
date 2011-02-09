class Admin::ShoutoutsController < ApplicationController
  layout 'admin', :except => [:show]
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']

  # GET /shoutouts
  # GET /shoutouts.xml
  def index
    @shoutouts = Shoutout.find(:all, :order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shoutouts }
    end
  end

  # GET /shoutouts/1
  # GET /shoutouts/1.xml
  def show
    @shoutout = Shoutout.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show", :layout => 'no_sidebar'}
      format.xml  { render :xml => @shoutout }
    end
  end

  # GET /shoutouts/new
  # GET /shoutouts/new.xml
  def new
    @shoutout = Shoutout.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shoutout }
    end
  end

  # GET /shoutouts/1/edit
  def edit
    @shoutout = Shoutout.find(params[:id])
  end

  # POST /shoutouts
  # POST /shoutouts.xml
  def create
    @shoutout = Shoutout.new(params[:shoutout])

    respond_to do |format|
      if @shoutout.save
        flash[:notice] = 'shoutout was successfully created.'
        format.html { redirect_to(admin_shoutout_path(@shoutout)) }
        format.xml  { render :xml => @shoutout, :status => :created, :location => @shoutout }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shoutout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shoutouts/1
  # PUT /shoutouts/1.xml
  def update
    @shoutout = Shoutout.find(params[:id])

    respond_to do |format|
      if @shoutout.update_attributes(params[:shoutout])
        flash[:notice] = 'shoutout was successfully updated.'
        format.html { redirect_to(admin_shoutout_path(@shoutout)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shoutout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shoutouts/1
  # DELETE /shoutouts/1.xml
  def destroy
    @shoutout = Shoutout.find(params[:id])
    @shoutout.destroy

    respond_to do |format|
      format.html { redirect_to(admin_shoutouts_url) }
      format.xml  { head :ok }
    end
  end
end
