class AddQuantityToCartItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :quantity, :integer
  end

  def self.down
    remove_column :cart_items, :quantity
  end
end
