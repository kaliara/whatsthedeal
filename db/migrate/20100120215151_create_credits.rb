class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.integer :user_id
      t.integer :referrer_user_id
      t.string :name
      t.string :code
      t.integer :use_limit

      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
