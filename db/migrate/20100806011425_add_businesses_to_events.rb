class AddBusinessesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :business_id, :integer, :default => 0
  end

  def self.down
    remove_column :events, :business_id
  end
end
