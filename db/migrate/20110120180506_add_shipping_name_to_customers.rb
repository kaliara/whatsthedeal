class AddShippingNameToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :shipping_name, :string
  end

  def self.down
    remove_column :customers, :shipping_name
  end
end
