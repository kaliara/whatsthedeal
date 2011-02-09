class AddCouponCodesAndInstructionsToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :coupon_instructions, :text
    add_column :deals, :has_coupon_code, :boolean, :default => false
    add_column :deals, :coupon_code_prefix, :string
    add_column :deals, :coupon_code_delta, :integer, :default => 0
  end

  def self.down
    remove_column :deals, :coupon_code_delta
    remove_column :deals, :coupon_code_prefix
    remove_column :deals, :has_coupon_code
    remove_column :deals, :coupon_instructions
  end
end
