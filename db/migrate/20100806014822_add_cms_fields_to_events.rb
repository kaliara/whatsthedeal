class AddCmsFieldsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :attendees, :integer, :default => 0
    add_column :events, :subscription_list_id, :integer, :default => 44
    add_column :events, :page_body, :text
  end

  def self.down
    remove_column :events, :page_body
    remove_column :events, :subscription_list_id
    remove_column :events, :attendees
  end
end
