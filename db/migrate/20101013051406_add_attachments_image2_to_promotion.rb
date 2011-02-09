class AddAttachmentsImage2ToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotions, :image2_file_name, :string
    add_column :promotions, :image2_content_type, :string
    add_column :promotions, :image2_file_size, :integer
    add_column :promotions, :image2_updated_at, :datetime
  end

  def self.down
    remove_column :promotions, :image2_file_name
    remove_column :promotions, :image2_content_type
    remove_column :promotions, :image2_file_size
    remove_column :promotions, :image2_updated_at
  end
end
