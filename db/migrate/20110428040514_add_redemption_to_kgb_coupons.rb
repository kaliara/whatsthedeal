class AddRedemptionToKgbCoupons < ActiveRecord::Migration
  def self.up
    add_column :kgb_coupons, :biz_used, :boolean, :default => false
    add_column :kgb_coupons, :used, :boolean, :default => false
    add_column :kgb_coupons, :mobile_used, :boolean, :default => false
    add_column :kgb_coupons, :redemption_date, :datetime
  end

  def self.down
    remove_column :kgb_coupons, :redemption_date
    remove_column :kgb_coupons, :mobile_used
    remove_column :kgb_coupons, :used
    remove_column :kgb_coupons, :biz_used
  end
end