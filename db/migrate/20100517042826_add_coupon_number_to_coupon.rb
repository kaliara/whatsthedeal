class AddCouponNumberToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :number, :integer, :default => 1
  end

  def self.down
    remove_column :coupons, :number
  end
end
