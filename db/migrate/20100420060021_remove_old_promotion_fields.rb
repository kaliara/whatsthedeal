class RemoveOldPromotionFields < ActiveRecord::Migration
  def self.up
    remove_column :promotions, :image
    remove_column :promotions, :description
  end

  def self.down
    add_column :promotions, :description, :text
    add_column :promotions, :image, :string
  end
end
