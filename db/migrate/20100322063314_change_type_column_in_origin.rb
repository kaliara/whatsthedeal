class ChangeTypeColumnInOrigin < ActiveRecord::Migration
  def self.up
    rename_column :origins, :type, :origin_type
  end

  def self.down
    rename_column :origins, :origin_type, :type
  end
end
