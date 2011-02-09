class UpdatePurchaserRateDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :businesses, :purchaser_rate, 50
  end

  def self.down
    change_column_default :businesses, :purchaser_rate, 0.5
  end
end
