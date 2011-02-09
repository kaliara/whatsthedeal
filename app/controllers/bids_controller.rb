class BidsController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application

  def new
    unless current_user
      redirect_away('/login')
      flash[:notice] = "In order to place a bid, you must first login or create an account"
    else
      @bid = Bid.new
      render :action => 'new'
    end
  end
  
  def create
    @bid = Bid.new
    @bid.item_id = params[:item_id]
    @bid.amount = params[:bid_amount]
    @bid.user = current_user
    @bid.save
    
    redirect_to item_url(@bid.item_id)
    flash[:notice] = "Your bid has been placed. Keep an eye on this page to see if you are the high bidder."
  end
end    