class RenameAmountInBusinessPayments < ActiveRecord::Migration
  def self.up
    rename_column :business_payments, :amount, :initial_amount
  end

  def self.down
    rename_column :business_payments, :initial_amount, :amount
  end
end