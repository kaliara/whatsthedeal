class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.integer :deal_id
      t.integer :user_id
      t.string :name
      t.text :description
      t.datetime :expiration

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
