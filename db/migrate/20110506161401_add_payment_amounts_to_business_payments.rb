class AddPaymentAmountsToBusinessPayments < ActiveRecord::Migration
  def self.up
    add_column :business_payments, :payment1_amount, :decimal, :precision => 10, :scale => 2, :default => 0
    add_column :business_payments, :payment2_amount, :decimal, :precision => 10, :scale => 2, :default => 0
  end

  def self.down
    remove_column :business_payments, :payment2_amount
    remove_column :business_payments, :payment1_amount
  end
end