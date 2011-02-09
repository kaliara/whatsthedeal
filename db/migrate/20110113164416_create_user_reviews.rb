class CreateUserReviews < ActiveRecord::Migration
  def self.up
    create_table :user_reviews do |t|
      t.integer :user_id
      t.boolean :reviewed, :default => false
      t.boolean :credit_given

      t.timestamps
    end
  end

  def self.down
    drop_table :user_reviews
  end
end
