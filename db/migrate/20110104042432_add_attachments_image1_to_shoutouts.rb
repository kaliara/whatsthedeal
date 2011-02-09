class AddAttachmentsImage1ToShoutouts < ActiveRecord::Migration
  def self.up
    add_column :shoutouts, :image1_file_name, :string
    add_column :shoutouts, :image1_content_type, :string
    add_column :shoutouts, :image1_file_size, :integer
    add_column :shoutouts, :image1_updated_at, :datetime
  end

  def self.down
    remove_column :shoutouts, :image1_file_name
    remove_column :shoutouts, :image1_content_type
    remove_column :shoutouts, :image1_file_size
    remove_column :shoutouts, :image1_updated_at
  end
end
