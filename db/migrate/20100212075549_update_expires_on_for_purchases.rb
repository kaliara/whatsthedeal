class UpdateExpiresOnForPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :card_expires_on_month, :integer
    add_column :purchases, :card_expires_on_year, :integer
    
    remove_column :purchases, :card_expires_on
  end

  def self.down
    add_column :purchases, :card_expires_on, :datetime
    
    remove_column :purchases, :card_expires_on_year
    remove_column :purchases, :card_expires_on_month
  end
end
