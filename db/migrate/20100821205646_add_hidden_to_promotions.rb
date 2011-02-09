class AddHiddenToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :hidden
  end
end
