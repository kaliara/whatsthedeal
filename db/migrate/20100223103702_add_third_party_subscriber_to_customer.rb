class AddThirdPartySubscriberToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :third_party_subscriber, :boolean
  end

  def self.down
    remove_column :customers, :third_party_subscriber
  end
end
