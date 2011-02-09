class CreateRaffles < ActiveRecord::Migration
  def self.up
    create_table :raffles do |t|
      t.string :header
      t.text :body
      t.datetime :rotation_start_date
      t.datetime :rotation_end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :raffles
  end
end
