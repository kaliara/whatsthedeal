class AddFeaturedToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :featured, :boolean
  end

  def self.down
    remove_column :deals, :featured
  end
end
