class AddLatitudeLongitudeToBusinesses < ActiveRecord::Migration
  def self.up
    add_column :businesses, :latitude, :string
    add_column :businesses, :longitude, :string
  end

  def self.down
    remove_column :businesses, :longitude
    remove_column :businesses, :latitude
  end
end