class AddBusinessIdToOrigins < ActiveRecord::Migration
  def self.up
    add_column :origins, :business_id, :integer
  end

  def self.down
    remove_column :origins, :business_id
  end
end
