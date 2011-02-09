class CreateDelayedEmails < ActiveRecord::Migration
  def self.up
    create_table :delayed_emails do |t|
      t.string :template
      t.integer :user_id
      t.datetime :delay_until
      t.boolean :emailed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :delayed_emails
  end
end
