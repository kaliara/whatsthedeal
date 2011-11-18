class AddAccessTokenToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :access_token, :string, :unique => true
  end

  def self.down
    remove_column :coupons, :access_token
  end
end
