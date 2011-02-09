class AddAdDescriptions6and7ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_description6, :string
    add_column :promotions, :ad_description7, :string
  end

  def self.down
    remove_column :promotions, :ad_description7
    remove_column :promotions, :ad_description6
  end
end