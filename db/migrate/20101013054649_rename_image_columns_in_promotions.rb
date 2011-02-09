class RenameImageColumnsInPromotions < ActiveRecord::Migration
  def self.up
    rename_column :promotions, :image1, :legacy_image1
    rename_column :promotions, :image2, :legacy_image2
    rename_column :promotions, :ad_image, :legacy_ad_image
  end

  def self.down
    rename_column :promotions, :legacy_ad_image, :ad_image
    rename_column :promotions, :legacy_image2
    rename_column :promotions, :legacy_image1
  end
end
