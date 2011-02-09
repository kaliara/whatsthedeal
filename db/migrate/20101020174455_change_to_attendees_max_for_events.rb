class ChangeToAttendeesMaxForEvents < ActiveRecord::Migration
  def self.up
    rename_column :events, :attendees, :attendees_max
  end

  def self.down
    rename_column :events, :attendees_max, :attendees
  end
end
