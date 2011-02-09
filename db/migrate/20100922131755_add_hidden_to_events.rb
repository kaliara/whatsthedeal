class AddHiddenToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :events, :hidden
  end
end
