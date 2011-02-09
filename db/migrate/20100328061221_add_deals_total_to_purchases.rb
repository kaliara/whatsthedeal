class AddDealsTotalToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :deals_total, :decimal, :default => 0
  end

  def self.down
    remove_column :purchases, :deals_total
  end
end
