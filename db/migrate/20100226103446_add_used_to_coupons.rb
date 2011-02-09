class AddUsedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :used, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :used
  end
end
