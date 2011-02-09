class AddGiftDetailsToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :gift_email, :string
    add_column :coupons, :gift_message, :text
    add_column :coupons, :gift_from, :string
    add_column :coupons, :gift_send_date, :datetime
  end

  def self.down
    remove_column :coupons, :gift_send_date
    remove_column :coupons, :gift_from
    remove_column :coupons, :gift_message
    remove_column :coupons, :gift_email
  end
end
