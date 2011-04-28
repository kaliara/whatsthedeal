class AddKgbDealIdToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :kgb_deal_id, :integer, :default => 1
  end

  def self.down
    remove_column :deals, :kgb_deal_id
  end
end