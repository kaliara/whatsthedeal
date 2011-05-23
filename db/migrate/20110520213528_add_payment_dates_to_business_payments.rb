class AddPaymentDatesToBusinessPayments < ActiveRecord::Migration
  def self.up
    add_column :business_payments, :payment1_date, :date
    add_column :business_payments, :payment2_date, :date
  end

  def self.down
    remove_column :business_payments, :payment2_date
    remove_column :business_payments, :payment1_date
  end
end