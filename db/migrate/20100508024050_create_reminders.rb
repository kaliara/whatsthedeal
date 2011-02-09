class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders, :force => true do |t|
      t.integer :promotion_id
      t.string :email
      t.boolean :emailed, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
