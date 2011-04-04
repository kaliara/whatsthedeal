class AddSubListsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gets_va_daily_deal_email, :boolean, :default => false
    add_column :users, :gets_md_daily_deal_email, :boolean, :default => false
  end

  def self.down
    remove_column :users, :gets_md_daily_deal_email
    remove_column :users, :gets_va_daily_deal_email
  end
end