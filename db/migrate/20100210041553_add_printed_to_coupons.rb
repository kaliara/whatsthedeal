class AddPrintedToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :printed, :boolean
  end

  def self.down
    remove_column :coupons, :printed
  end
end
