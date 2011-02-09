class AddAdDescription3ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_description3, :string
  end

  def self.down
    remove_column :promotions, :ad_description3
  end
end
