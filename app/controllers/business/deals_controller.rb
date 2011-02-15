class Business::DealsController < ApplicationController
  layout 'business'
  before_filter :impersonate_business
  before_filter :business_required 
  
  # GET /deals
  # GET /deals.xml
  def index
    if params[:promotion_id]
      @promotion = Promotion.find(params[:promotion_id])
      @deals = @promotion.deals
    else
      @deals = Deal.all
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deals }
    end
  end

  # GET /deals/1
  # GET /deals/1.xml
  def show
    @deal = Deal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deal }
    end
  end

end