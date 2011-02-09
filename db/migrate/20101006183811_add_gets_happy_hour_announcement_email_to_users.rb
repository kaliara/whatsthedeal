class AddGetsHappyHourAnnouncementEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gets_happy_hour_announcement_email, :boolean, :default => false
  end

  def self.down
    remove_column :users, :gets_happy_hour_announcement_email
  end
end
