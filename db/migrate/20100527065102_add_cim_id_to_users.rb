class AddCimIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :customer_cim_id, :string
  end

  def self.down
    remove_column :users, :customer_cim_id
  end
end
