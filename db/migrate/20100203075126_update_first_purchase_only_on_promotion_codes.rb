class UpdateFirstPurchaseOnlyOnPromotionCodes < ActiveRecord::Migration
  def self.up
    change_column :promotion_codes, :restricted, :boolean
  end

  def self.down
    change_column :promotion_codes, :restricted, :string
  end
end
