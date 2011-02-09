class AddCouponCodeNumberBaseToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :coupon_code_number_base, :decimal, :default => 16
  end

  def self.down
    remove_column :deals, :coupon_code_number_base
  end
end
