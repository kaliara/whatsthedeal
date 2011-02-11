class AddSlugNameToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :slug, :string
  end

  def self.down
    remove_column :promotions, :slug
  end
end
