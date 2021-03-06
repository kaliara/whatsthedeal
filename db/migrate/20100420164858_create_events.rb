class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :header
      t.string :title
      t.string :image
      t.text :description
      t.datetime :rotation_start_date
      t.datetime :rotation_end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
