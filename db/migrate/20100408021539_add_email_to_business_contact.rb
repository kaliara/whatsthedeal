class AddEmailToBusinessContact < ActiveRecord::Migration
  def self.up
    add_column :businesses, :email, :string
  end

  def self.down
    remove_column :businesses, :email
  end
end
