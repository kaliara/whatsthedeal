class AddHiddenToRaffles < ActiveRecord::Migration
  def self.up
    add_column :raffles, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :raffles, :hidden
  end
end