class AddGetsDailyDealEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gets_daily_deal_email, :boolean, :default => false
  end

  def self.down
    remove_column :users, :gets_daily_deal_email
  end
end
