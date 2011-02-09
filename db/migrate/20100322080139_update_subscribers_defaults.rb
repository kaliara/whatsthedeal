class UpdateSubscribersDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :subscribers, :origin_id, 1
  end

  def self.down
    change_column_default :subscribers, :origin_id, 0
  end
end
