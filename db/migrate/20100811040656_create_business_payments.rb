class CreateBusinessPayments < ActiveRecord::Migration
  def self.up
    create_table :business_payments do |t|
      t.integer :business_id
      t.integer :promotion_id
      t.boolean :paid, :default => false
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :business_payments
  end
end
