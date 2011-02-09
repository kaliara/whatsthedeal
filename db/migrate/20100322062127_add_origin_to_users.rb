class AddOriginToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :origin_id, :integer, :default => 0
  end

  def self.down
    remove_column :users, :origin_id
  end
end
