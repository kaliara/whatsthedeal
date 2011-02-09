class AddFirstPurchaseOnlyToPromotionCodes < ActiveRecord::Migration
  def self.up
    add_column :promotion_codes, :restricted, :string
  end

  def self.down
    remove_column :promotion_codes, :restricted
  end
end
