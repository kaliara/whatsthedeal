class AddHalfpricedcFeaturedToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :halfpricedc_featured, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :halfpricedc_featured
  end
end