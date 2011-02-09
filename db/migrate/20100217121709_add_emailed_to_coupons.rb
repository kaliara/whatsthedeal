class AddEmailedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :emailed, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :emailed
  end
end
