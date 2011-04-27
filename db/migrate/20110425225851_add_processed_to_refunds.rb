class AddProcessedToRefunds < ActiveRecord::Migration
  def self.up
    add_column :refunds, :processed, :boolean, :default => false
  end

  def self.down
    remove_column :refunds, :processed
  end
end