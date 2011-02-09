class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zipcode
      t.boolean :female
      t.datetime :birthdate
      t.boolean :newsletter_subscriber

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
