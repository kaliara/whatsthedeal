class AddEndDateToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :end_date, :datetime
  end

  def self.down
    remove_column :items, :end_date
  end
end