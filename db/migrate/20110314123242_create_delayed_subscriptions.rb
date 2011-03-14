class CreateDelayedSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :delayed_subscriptions do |t|
      t.string :email
      t.integer :list
      t.string :referrer
      t.boolean :subscribed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :delayed_subscriptions
  end
end
