class CreateKgbCoupons < ActiveRecord::Migration
  def self.up
    create_table :kgb_coupons do |t|
      t.datetime :date_exported
      t.string :transactions_transaction_id
      t.integer :transactions_deal_id
      t.integer :transactions_user_id
      t.integer :transactions_quantity
      t.decimal :transactions_total_amount, :precision => 10, :scale => 2
      t.datetime :transactions_timestamp
      t.string :users_first_name
      t.string :users_last_name
      t.string :users_email
      t.integer :deals_merchant_id
      t.string :deals_title
      t.decimal :deals_price, :precision => 10, :scale => 2
      t.datetime :deals_coupon_expires
      t.string :merchants_name

      t.timestamps
    end
  end

  def self.down
    drop_table :kgb_coupons
  end
end
