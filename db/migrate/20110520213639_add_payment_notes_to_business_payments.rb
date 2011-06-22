class AddPaymentNotesToBusinessPayments < ActiveRecord::Migration
  def self.up
    add_column :business_payments, :payment2_notes, :string
    rename_column :business_payments, :notes, :payment1_notes
  end

  def self.down
    rename_column :business_payments, :payment1_notes, :notes
    remove_column :business_payments, :payment2_notes
  end
end