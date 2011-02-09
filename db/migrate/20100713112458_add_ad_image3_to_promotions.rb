class AddAdImage3ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_image3, :string
  end

  def self.down
    remove_column :promotions, :ad_image3
  end
end
