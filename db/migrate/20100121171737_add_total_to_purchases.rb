class AddTotalToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :total, :decimal
  end

  def self.down
    remove_column :purchases, :total
  end
end
