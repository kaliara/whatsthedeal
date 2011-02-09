class AddActiveToPromotionCodes < ActiveRecord::Migration
  def self.up
    add_column :promotion_codes, :active, :boolean, :default => true
  end

  def self.down
    remove_column :promotion_codes, :active
  end
end
