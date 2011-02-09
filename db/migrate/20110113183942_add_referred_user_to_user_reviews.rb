class AddReferredUserToUserReviews < ActiveRecord::Migration
  def self.up
    add_column :user_reviews, :referred_user_id, :integer
  end

  def self.down
    remove_column :user_reviews, :referred_user_id
  end
end