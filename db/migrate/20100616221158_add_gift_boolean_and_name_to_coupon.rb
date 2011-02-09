class AddGiftBooleanAndNameToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :gift, :boolean, :default => false
    add_column :coupons, :gift_name, :string
  end

  def self.down
    remove_column :coupons, :gift_name
    remove_column :coupons, :gift
  end
end
