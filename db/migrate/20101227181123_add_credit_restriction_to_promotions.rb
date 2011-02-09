class AddCreditRestrictionToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :credit_restriction, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :credit_restriction
  end
end