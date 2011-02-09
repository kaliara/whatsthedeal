class AddBizUsedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :biz_used, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :biz_used
  end
end
