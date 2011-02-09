class AddWashingtonianOverrideToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :washingtonian_featured, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :washingtonian_featured
  end
end
