class AddDeletedToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :purchases, :deleted
  end
end