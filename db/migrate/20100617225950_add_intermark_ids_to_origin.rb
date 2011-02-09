class AddIntermarkIdsToOrigin < ActiveRecord::Migration
  def self.up
    add_column :origins, :sub_id, :string
    add_column :origins, :placement_id, :string
  end

  def self.down
    remove_column :origins, :placement_id
    remove_column :origins, :sub_id
  end
end
