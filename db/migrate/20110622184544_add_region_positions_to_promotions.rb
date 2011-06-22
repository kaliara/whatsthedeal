class AddRegionPositionsToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :dc_position, :integer, :default => 99
    add_column :promotions, :nova_position, :integer, :default => 99
  end

  def self.down
    remove_column :promotions, :nova_position
    remove_column :promotions, :dc_position
  end
end