class CreateMiscs < ActiveRecord::Migration
  def self.up
    create_table :miscs, :force => true do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :miscs
  end
end