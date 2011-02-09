class AddGiftDetailsToCartItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :gift_message, :text
    add_column :cart_items, :gift_from, :string
    add_column :cart_items, :gift_email, :string
    add_column :cart_items, :gift_send_date, :datetime
  end

  def self.down
    remove_column :cart_items, :gift_send_date
    remove_column :cart_items, :gift_email
    remove_column :cart_items, :gift_from
    remove_column :cart_items, :gift_message
  end
end
