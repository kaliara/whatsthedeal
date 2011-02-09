class AddPartnerIdToUsersAndSubscribers < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_id, :integer, :default => 0
    add_column :subscribers, :partner_id, :integer, :default => 0
  end

  def self.down
    remove_column :subscribers, :partner_id
    remove_column :users, :partner_id
  end
end
