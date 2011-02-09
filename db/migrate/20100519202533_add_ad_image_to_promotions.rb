class AddAdImageToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_image, :string
  end

  def self.down
    remove_column :promotions, :ad_image
  end
end
