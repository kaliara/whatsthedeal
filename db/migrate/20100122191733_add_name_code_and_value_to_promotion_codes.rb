class AddNameCodeAndValueToPromotionCodes < ActiveRecord::Migration
  def self.up
    add_column :promotion_codes, :name, :string
    add_column :promotion_codes, :value, :decimal
    add_column :promotion_codes, :use_limit, :integer
  end

  def self.down
    remove_column :promotion_codes, :use_limit
    remove_column :promotion_codes, :value
    remove_column :promotion_codes, :name
  end
end
