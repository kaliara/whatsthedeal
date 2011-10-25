class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :persistence_token
    add_index :promotions, [:start_date, :end_date, :active, :hidden], :name => 'promotions_idx'
    add_index :coupons, [:deleted, :refunded, :deal_id], :name => 'coupons_idx'
  end

  def self.down
    remove_index :coupons, :name => 'coupons_idx'
    remove_index :promotions, :name => 'promotions_idx'
    remove_index :users, :persistence_token
  end
end