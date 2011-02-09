class CreateBusinesses < ActiveRecord::Migration
  def self.up
    create_table :businesses do |t|
      t.integer :user_id
      t.string :name
      t.string :phone
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :website

      t.timestamps
    end
  end

  def self.down
    drop_table :businesses
  end
end
