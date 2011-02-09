class AddRedemptionDateToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :redemption_date, :datetime
  end

  def self.down
    remove_column :coupons, :redemption_date
  end
end