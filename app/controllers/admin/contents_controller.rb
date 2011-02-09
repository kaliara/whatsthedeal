class Admin::ContentsController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /contents
  # GET /contents.xml
  def index
    @contents = Content.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
    end
  end

  # GET /contents/new
  # GET /contents/new.xml
  def new
    session[:return_to] = request.referer
    
    @content = Content.new
    @content.name = params[:name] unless params[:name].blank?
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content }
    end
  end

  # GET /contents/1/edit
  def edit
    @content = Content.find(params[:id])
  end

  # POST /contents
  # POST /contents.xml
  def create
    @content = Content.new(params[:content])

    respond_to do |format|
      if @content.save
        flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to :action => 'index' }
        format.xml  { render :xml => @content, :status => :created, :location => @content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contents/1
  # PUT /contents/1.xml
  def update
    @content = Content.find(params[:id])

    respond_to do |format|
      if @content.update_attributes(params[:content])
        flash[:notice] = 'Content was successfully updated.'
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.xml
  def destroy
    @content = Content.find(params[:id])
    @content.destroy

    respond_to do |format|
      format.html { redirect_to(admin_contents_path) }
      format.xml  { head :ok }
    end
  end
end
