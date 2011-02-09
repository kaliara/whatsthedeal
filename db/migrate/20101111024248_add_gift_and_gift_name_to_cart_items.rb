class AddGiftAndGiftNameToCartItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :gift, :boolean, :default => false
    add_column :cart_items, :gift_name, :string
  end

  def self.down
    remove_column :cart_items, :gift_name
    remove_column :cart_items, :gift
  end
end
