class AddAdDescriptionToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_description, :text
  end

  def self.down
    remove_column :promotions, :ad_description
  end
end
