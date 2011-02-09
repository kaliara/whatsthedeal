class CreateCartItems < ActiveRecord::Migration
  def self.up
    create_table :cart_items do |t|
      t.integer :cart_id
      t.integer :deal_id
      t.integer :credit_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cart_items
  end
end
