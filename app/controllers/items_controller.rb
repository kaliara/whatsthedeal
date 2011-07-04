class ItemsController < ApplicationController
  before_filter :impersonate_customer, :force_full_site
  layout :hyrbrid_layout_application

  def index
    @promotions = Promotion.find(268, 269, 270, 272)
    @side_promotions = Promotion.sidebar([0], region)
    @items = Item.all
    render :action => 'index'
  end
  
  def show
    redirect_to :action => 'index'
    # @side_promotions = Promotion.sidebar(0, region)
    # unless current_user
    #   redirect_away('/login')
    #   flash[:notice] = "In order to place a bid, you must first login or create an account"
    # else
    #   @item = Item.find(params[:id])
    #   @bid = Bid.new
    #   render :action => 'show'
    # end
  end
  
end