class AddRotationToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :rotation_category, :integer, :default => 0
    add_column :contents, :rotation_item, :integer, :default => 0
  end

  def self.down
    remove_column :contents, :rotation_item
    remove_column :contents, :rotation
  end
end
