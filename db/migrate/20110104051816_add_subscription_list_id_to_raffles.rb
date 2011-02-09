class AddSubscriptionListIdToRaffles < ActiveRecord::Migration
  def self.up
    add_column :raffles, :subscription_list_id, :integer, :default => 44
  end

  def self.down
    remove_column :raffles, :subscription_list_id
  end
end