class AddUnlikelySubscriberToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unlikely_subscriber, :integer, :default => 0
  end

  def self.down
    remove_column :users, :unlikely_subscriber
  end
end