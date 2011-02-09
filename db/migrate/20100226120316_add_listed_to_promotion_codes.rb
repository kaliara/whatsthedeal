class AddListedToPromotionCodes < ActiveRecord::Migration
  def self.up
    add_column :promotion_codes, :listed, :boolean, :default => false
  end

  def self.down
    remove_column :promotion_codes, :listed
  end
end
