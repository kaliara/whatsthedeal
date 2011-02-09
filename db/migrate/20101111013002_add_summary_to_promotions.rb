class AddSummaryToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :summary, :text
  end

  def self.down
    remove_column :promotions, :summary
  end
end
