class AddThumbnailToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotions, :image, :string
  end

  def self.down
    remove_column :promotions, :image
  end
end
