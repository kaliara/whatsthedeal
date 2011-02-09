class UpdateUserOriginDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :users, :origin_id, 1
  end

  def self.down
    change_column_default :users, :origin_id, 0
  end
end
