class AddPartnerToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :partner_id, :integer, :default => 0
  end

  def self.down
    remove_column :promotions, :partner_id
  end
end
