class AddShippingAddressToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :shipping_address1, :string
    add_column :purchases, :shipping_address2, :string
    add_column :purchases, :shipping_city, :string
    add_column :purchases, :shipping_state, :string
    add_column :purchases, :shipping_zipcode, :string
    add_column :purchases, :shipping_name, :string
  end

  def self.down
    remove_column :purchases, :shipping_name
    remove_column :purchases, :shipping_zipcode
    remove_column :purchases, :shipping_state
    remove_column :purchases, :shipping_city
    remove_column :purchases, :shipping_address2
    remove_column :purchases, :shipping_address1
  end
end