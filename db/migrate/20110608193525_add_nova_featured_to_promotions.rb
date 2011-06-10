class AddNovaFeaturedToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :nova_featured, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :nova_featured
  end
end