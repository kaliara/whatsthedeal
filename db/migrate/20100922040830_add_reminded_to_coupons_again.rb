class AddRemindedToCouponsAgain < ActiveRecord::Migration
  def self.up
    add_column :coupons, :reminded, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :reminded
  end
end
