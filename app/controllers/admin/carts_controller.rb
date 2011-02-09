class Admin::CartsController < ApplicationController
  layout 'admin'
  before_filter :admin_required 
  
  # GET /carts
  # GET /carts.xml
  def index
    @carts = Cart.find(:all, :order => 'created_at DESC', :limit => 100)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @carts }
    end
  end

  # GET /carts/1
  # GET /carts/1.xml
  def show
    @cart = Cart.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @carts }
    end
  end

  # PUT /carts/1
   # PUT /carts/1.xml
   def update
     @cart = Cart.find(params[:id])

     respond_to do |format|
       if @cart.update_attributes(params[:cart])
         flash[:notice] = 'Cart was successfully updated.'
         format.html { redirect_to(admin_carts_url) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @cart.errors, :status => :unprocessable_entity }
       end
     end
   end

   # DELETE /carts/1
   # DELETE /carts/1.xml
   def destroy
     @cart = Cart.find(params[:id])
     @cart.destroy

     respond_to do |format|
       format.html { redirect_to(admin_carts_url) }
       format.xml  { head :ok }
     end
   end
   
   def clear
     @carts_cleared = 0 
     
     if params[:id].to_i > 0
       @prohibited_promotions = [Promotion.find(params[:id])]
     else
       @prohibited_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date < ?', Time.now, Time.now]) + Promotion.all.delete_if{|p| !p.sold_out?}
     end

     @prohibited_promotions.collect{|p| puts p.id}

     unless @prohibited_promotions.empty?
       CartItem.find(:all, :conditions => {:deal_id => @prohibited_promotions.collect{|p| p.deals.collect{|d| d.id}}.flatten}).each do |ci|
         ci.destroy
         @carts_cleared += 1
       end
     end
     
     render :action => 'clear'
   end
end