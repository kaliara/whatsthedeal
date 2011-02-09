class AddScaleToPriceFieldsThroughout < ActiveRecord::Migration
  def self.up
    change_column :businesses, :purchaser_rate,   :decimal, :precision => 10, :scale => 2, :default => 50
    change_column :credits, :value,               :decimal, :precision => 10, :scale => 2
    change_column :deals, :price,                 :decimal, :precision => 10, :scale => 2 
    change_column :deals, :value,                 :decimal, :precision => 10, :scale => 2
    change_column :promotion_codes, :value,       :decimal, :precision => 10, :scale => 2
    change_column :purchases, :total,             :decimal, :precision => 10, :scale => 2
    change_column :purchases, :deals_total,       :decimal, :precision => 10, :scale => 2
    change_column :promotions, :profit_percentage,:decimal, :precision => 10, :scale => 2, :default => 30
  end

  def self.down
    change_column :promotions, :profit_percentage, :integer
    change_column :purchases, :deals_total, :integer
    change_column :purchases, :total, :integer
    change_column :promotion_codes, :value, :integer
    change_column :deals, :value, :integer
    change_column :deals, :price, :integer
    change_column :credits, :value, :integer
    change_column :businesses, :purchaser_rate, :integer
  end
end
