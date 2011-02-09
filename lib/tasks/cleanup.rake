namespace :cleanup do

  desc "cleans up cart items of deals that expired"
  task :cart_items => :environment do 
    @prohibited_promotions = Promotion.find(:all, :conditions => ['start_date < ? and end_date < ?', Time.now, Time.now]) + Promotion.all.delete_if{|p| !p.sold_out?}
    
    puts "Looks like there are #{@prohibited_promotions.size} promotions that are no good anymore."

    unless @prohibited_promotions.empty?
      CartItem.find(:all, :conditions => {:deal_id => @prohibited_promotions.collect{|p| p.deals.collect{|d| d.id}}.flatten}).each do |ci|
        ci.destroy
      end
    end
  end

  desc "cleans up carts that are more than a week old"
  task :carts => :environment do 
    @bad_carts = Cart.find(:all, :conditions => ['updated_at < ?', 1.week.ago])
    
    puts "Cleaning up #{@bad_carts.size} carts..."

    unless @bad_carts.empty?
      @bad_carts.each do |c|
        c.destroy
      end
    end
  end

  desc "cleans up credits that are more than two weeks old and not tied to a user or purchase"
  task :credits => :environment do 
    @bad_credits = Credit.find(:all, :conditions => ['user_id is null and updated_at < ?', 4.weeks.ago])
    
    puts "Cleaning up #{@bad_credits.size} credits..."

    unless @bad_credits.empty?
      @bad_credits.each do |c|
        c.destroy
      end
    end
  end
end