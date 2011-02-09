class AddLatitudeLongitudeToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :latitude, :string
    add_column :customers, :longitude, :string
  end

  def self.down
    remove_column :customers, :longitude
    remove_column :customers, :latitude
  end
end
