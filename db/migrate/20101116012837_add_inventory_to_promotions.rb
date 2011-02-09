class AddInventoryToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :inventory, :integer, :default => 9999
  end

  def self.down
    remove_column :promotions, :inventory
  end
end
