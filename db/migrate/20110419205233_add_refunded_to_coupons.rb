class AddRefundedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :refunded, :boolean, :default => false
    add_column :coupons, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :deleted
    remove_column :coupons, :refunded
  end
end