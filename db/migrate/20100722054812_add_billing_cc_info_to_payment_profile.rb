class AddBillingCcInfoToPaymentProfile < ActiveRecord::Migration
  def self.up
    add_column :payment_profiles, :billing_cc_last_four, :string
    add_column :payment_profiles, :billing_cc_year, :string
    add_column :payment_profiles, :billing_address1, :string
    add_column :payment_profiles, :billing_address2, :string
    add_column :payment_profiles, :billing_city, :string
    add_column :payment_profiles, :billing_state, :string
    add_column :payment_profiles, :billing_zip, :string
    add_column :payment_profiles, :billing_first_name, :string
    add_column :payment_profiles, :billing_last_name, :string
  end

  def self.down
    remove_column :payment_profiles, :billing_last_name
    remove_column :payment_profiles, :billing_first_name
    remove_column :payment_profiles, :billing_zip
    remove_column :payment_profiles, :billing_state
    remove_column :payment_profiles, :billing_city
    remove_column :payment_profiles, :billing_address2
    remove_column :payment_profiles, :billing_address1
    remove_column :payment_profiles, :billing_cc_year
    remove_column :payment_profiles, :billing_cc_last_four
  end
end
