class AddGiftAccessTokenToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :gift_access_token, :string
  end

  def self.down
    remove_column :coupons, :gift_access_token
  end
end