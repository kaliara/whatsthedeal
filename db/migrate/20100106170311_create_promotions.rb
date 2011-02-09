class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.string :name
      t.text :description
      t.integer :quota
      t.boolean :featured
      t.boolean :active
      t.datetime :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :promotions
  end
end
