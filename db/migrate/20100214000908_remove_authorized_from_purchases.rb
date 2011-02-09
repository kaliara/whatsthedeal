class RemoveAuthorizedFromPurchases < ActiveRecord::Migration
  def self.up
    remove_column :purchases, :authorized
  end

  def self.down
    add_column :purchases, :authorized, :boolean
  end
end
