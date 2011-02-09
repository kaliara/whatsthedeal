class AddExternalUrlToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :external_url, :string
  end

  def self.down
    remove_column :promotions, :external_url
  end
end
