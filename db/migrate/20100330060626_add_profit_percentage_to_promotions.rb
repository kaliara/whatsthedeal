class AddProfitPercentageToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :profit_percentage, :decimal, :default => 30.00, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :promotions, :profit_percentage
  end
end
