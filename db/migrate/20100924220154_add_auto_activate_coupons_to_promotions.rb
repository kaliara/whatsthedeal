class AddAutoActivateCouponsToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :auto_activate_coupons, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :auto_activate_coupons
  end
end
