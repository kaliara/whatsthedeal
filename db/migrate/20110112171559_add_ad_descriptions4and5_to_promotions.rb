class AddAdDescriptions4and5ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_description4, :string
    add_column :promotions, :ad_description5, :string
  end

  def self.down
    remove_column :promotions, :ad_description5
    remove_column :promotions, :ad_description4
  end
end