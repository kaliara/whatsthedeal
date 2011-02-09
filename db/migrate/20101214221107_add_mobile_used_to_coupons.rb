class AddMobileUsedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :mobile_used, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :mobile_used
  end
end