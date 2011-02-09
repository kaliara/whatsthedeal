class Admin::PurchasesController < ApplicationController
  layout 'admin'
  before_filter :staff_required
  before_filter :admin_required, :only => ['destroy']
  
  # GET /purchases
  # GET /purchases.xml
  def index
    if params[:q] =~ /\@/
      @type = "Email"
      @purchases = Purchase.find(:all, :conditions => {:user_id => User.find_by_email(params[:q]).id}, :order => 'created_at DESC')
    elsif params[:q] =~ /\d+/
      @type = "Invoice Number"
      @purchases = Purchase.find_by_invoice_number(params[:q]).to_a
    else
      @purchases = Purchase.find(:all, :order => 'created_at DESC', :limit => 20)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
    end
  end

  # GET /purchases/1
  # GET /purchases/1.xml
  def show
    @purchase = Purchase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase }
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @purchase = Purchase.find(params[:id])
    @purchase.destroy

    respond_to do |format|
      format.html { redirect_to(admin_purchases_url) }
      format.xml  { head :ok }
    end
  end

end