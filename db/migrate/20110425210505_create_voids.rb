class CreateVoids < ActiveRecord::Migration
  def self.up
    create_table :voids do |t|
      t.integer :purchase_id
      t.boolean :processed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :voids
  end
end
