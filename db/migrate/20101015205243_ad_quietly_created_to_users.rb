class AdQuietlyCreatedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :quietly_created, :boolean, :default => false
    add_column :customers, :quietly_created, :boolean, :default => false
  end

  def self.down
    remove_column :customers, :quietly_created
    remove_column :users, :quietly_created
  end
end
