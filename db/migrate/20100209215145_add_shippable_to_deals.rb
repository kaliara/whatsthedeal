class AddShippableToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :shippable, :boolean
  end

  def self.down
    remove_column :deals, :shippable
  end
end
