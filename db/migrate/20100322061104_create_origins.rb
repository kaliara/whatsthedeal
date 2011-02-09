class CreateOrigins < ActiveRecord::Migration
  def self.up
    create_table :origins do |t|
      t.string :name
      t.integer :type
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :origins
  end
end
