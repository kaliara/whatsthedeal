class AddPositionToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :position, :integer, :default => 0
  end

  def self.down
    remove_column :promotions, :position
  end
end
