class AddPartialPaymentsToBusinessPayments < ActiveRecord::Migration
  def self.up
    add_column :business_payments, :payment1_paid, :boolean, :default => false
    add_column :business_payments, :payment2_paid, :boolean, :default => false
  end

  def self.down
    remove_column :business_payments, :payment2_paid
    remove_column :business_payments, :payment1_paid
  end
end