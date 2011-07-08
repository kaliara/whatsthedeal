class AddDontSendReminderToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :send_reminders, :boolean, :default => true
  end

  def self.down
    remove_column :promotions, :send_reminders
  end
end