class AddRestrictionsToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotions, :restrictions, :text
  end

  def self.down
    remove_column :promotions, :restrictions
  end
end
