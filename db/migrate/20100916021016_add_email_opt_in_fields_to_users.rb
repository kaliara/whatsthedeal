class AddEmailOptInFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gets_coupon_expiring_email, :boolean, :default => true
    add_column :users, :gets_referral_notification_email, :boolean, :default => true
    add_column :users, :gets_coupon_ready_email, :boolean, :default => true
  end

  def self.down
    remove_column :users, :gets_coupon_ready_email
    remove_column :users, :gets_referral_notification_email
    remove_column :users, :gets_coupon_expiring_email
  end
end
