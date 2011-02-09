class AddPromotionCodeIdToCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :promotion_code_id, :integer
  end

  def self.down
    remove_column :credits, :promotion_code_id
  end
end
