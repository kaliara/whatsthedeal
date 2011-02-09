class AddAdDescription2ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_description2, :string
  end

  def self.down
    remove_column :promotions, :ad_description2
  end
end
