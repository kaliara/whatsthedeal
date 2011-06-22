class AddCityIdToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :city_id, :integer, :default => 0
  end

  def self.down
    remove_column :promotions, :city_id
  end
end