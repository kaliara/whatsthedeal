class AddSidePromotionsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :side_promotion_1, :integer
    add_column :events, :side_promotion_2, :integer
    add_column :events, :side_promotion_3, :integer
  end

  def self.down
    remove_column :events, :side_promotion_3
    remove_column :events, :side_promotion_2
    remove_column :events, :side_promotion_1
  end
end