class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer :business_id
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zipcode

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
