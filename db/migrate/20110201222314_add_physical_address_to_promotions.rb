class AddPhysicalAddressToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :physical_address, :boolean, :default => true
  end

  def self.down
    remove_column :promotions, :physical_address
  end
end
