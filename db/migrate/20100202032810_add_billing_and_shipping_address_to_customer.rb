class AddBillingAndShippingAddressToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :shipping_street1, :string
    add_column :customers, :shipping_street2, :string
    add_column :customers, :shipping_city, :string
    add_column :customers, :shipping_state, :string
    add_column :customers, :shipping_zipcode, :string
    add_column :customers, :billing_street1, :string
    add_column :customers, :billing_street2, :string
    add_column :customers, :billing_city, :string
    add_column :customers, :billing_state, :string
    add_column :customers, :billing_zipcode, :string
  end

  def self.down
    remove_column :customers, :billing_zipcode
    remove_column :customers, :billing_state
    remove_column :customers, :billing_city
    remove_column :customers, :billing_street2
    remove_column :customers, :billing_street1
    remove_column :customers, :shipping_zipcode
    remove_column :customers, :shipping_state
    remove_column :customers, :shipping_city
    remove_column :customers, :shipping_street2
    remove_column :customers, :shipping_street1
  end
end
