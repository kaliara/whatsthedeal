class AddPaymentInfoToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :ip_address, :string
    add_column :purchases, :first_name, :string
    add_column :purchases, :last_name, :string
    add_column :purchases, :card_type, :string
    add_column :purchases, :card_number_masked, :string
    add_column :purchases, :card_expires_on, :string
    add_column :purchases, :billing_street1, :string
    add_column :purchases, :billing_street2, :string
    add_column :purchases, :billing_city, :string
    add_column :purchases, :billing_state, :string
    add_column :purchases, :billing_zipcode, :string
    add_column :purchases, :success, :boolean
    add_column :purchases, :authorized, :boolean
    add_column :purchases, :authorization, :string
    add_column :purchases, :message, :string
    add_column :purchases, :params, :text
  end

  def self.down
    remove_column :purchases, :ip_address
    remove_column :purchases, :first_name
    remove_column :purchases, :last_name
    remove_column :purchases, :card_type
    remove_column :purchases, :card_number_masked
    remove_column :purchases, :card_expires_on
    remove_column :purchases, :billing_street1
    remove_column :purchases, :billing_street2
    remove_column :purchases, :billing_city
    remove_column :purchases, :billing_state
    remove_column :purchases, :billing_zipcode
    remove_column :purchases, :success
    remove_column :purchases, :authorized
    remove_column :purchases, :authorization
    remove_column :purchases, :message
    remove_column :purchases, :params, :text
  end
end
