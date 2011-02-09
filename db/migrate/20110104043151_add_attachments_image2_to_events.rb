class AddAttachmentsImage2ToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :image2_file_name, :string
    add_column :events, :image2_content_type, :string
    add_column :events, :image2_file_size, :integer
    add_column :events, :image2_updated_at, :datetime
  end

  def self.down
    remove_column :events, :image2_file_name
    remove_column :events, :image2_content_type
    remove_column :events, :image2_file_size
    remove_column :events, :image2_updated_at
  end
end
