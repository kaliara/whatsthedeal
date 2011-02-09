class AddPurchaserRateToBusinesses < ActiveRecord::Migration
  def self.up
    add_column :businesses, :purchaser_rate, :decimal, :default => 0.5
  end

  def self.down
    remove_column :businesses, :purchaser_rate
  end
end
