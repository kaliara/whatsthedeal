class AddAdImage2ToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :ad_image2, :string
  end

  def self.down
    remove_column :promotions, :ad_image2
  end
end
