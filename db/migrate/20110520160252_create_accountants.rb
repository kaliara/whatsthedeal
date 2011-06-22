class CreateAccountants < ActiveRecord::Migration
  def self.up
    create_table :accountants do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :accountants
  end
end
