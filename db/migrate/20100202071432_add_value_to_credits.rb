class AddValueToCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :value, :decimal
  end

  def self.down
    remove_column :credits, :value
  end
end
