class AddGrabBagToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :grab_bag, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :grab_bag
  end
end