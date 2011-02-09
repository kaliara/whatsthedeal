class AddEarlyBirdDiscountToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :early_bird_discount, :decimal, :precision => 10, :scale => 2, :default => 0
  end

  def self.down
    remove_column :deals, :early_bird_discount
  end
end
