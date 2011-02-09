class AddBusinessToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotions, :business_id, :integer
  end

  def self.down
    remove_column :promotions, :business_id
  end
end
