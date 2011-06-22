class RenameFeaturedToDcFeaturedForPromotions < ActiveRecord::Migration
  def self.up
    rename_column :promotions, :featured, :dc_featured
  end

  def self.down
    rename_column :promotions, :dc_featured, :featured
  end
end