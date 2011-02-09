class AddPartnerIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :partner_id, :integer, :default => 0
  end

  def self.down
    remove_column :purchases, :partner_id
  end
end
