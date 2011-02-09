class AddSubscriberRateToBusinesses < ActiveRecord::Migration
  def self.up
    add_column :businesses, :subscriber_rate, :decimal, :default => 0.5, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :businesses, :subscriber_rate
  end
end
