class AddCouponCodeStartToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :coupon_code_start, :integer, :default => 27
  end

  def self.down
    remove_column :deals, :coupon_code_start
  end
end
