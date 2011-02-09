class AddPurchaseIdToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :purchase_id, :integer
  end

  def self.down
    remove_column :coupons, :purchase_id
  end
end
