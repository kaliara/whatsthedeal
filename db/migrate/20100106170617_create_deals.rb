class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.integer :promotion_id
      t.string :code
      t.string :name
      t.decimal :price
      t.decimal :value
      t.text :description
      t.integer :purchase_limit
      t.integer :inventory
      t.string :coupon_name
      t.text :coupon_description
      t.datetime :coupon_expiration

      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
