class AddTempToSubs < ActiveRecord::Migration
  def self.up
    add_column :subscribers, :fist_name, :string
    add_column :subscribers, :last_name, :string
    add_column :subscribers, :zipcode, :string
  end

  def self.down
    remove_column :subscribers, :zipcode
    remove_column :subscribers, :last_name
    remove_column :subscribers, :fist_name
  end
end
