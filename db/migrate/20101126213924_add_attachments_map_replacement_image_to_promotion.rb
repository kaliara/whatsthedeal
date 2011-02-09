class AddAttachmentsMapReplacementImageToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotions, :map_replacement_image_file_name, :string
    add_column :promotions, :map_replacement_image_content_type, :string
    add_column :promotions, :map_replacement_image_file_size, :integer
    add_column :promotions, :map_replacement_image_updated_at, :datetime
  end

  def self.down
    remove_column :promotions, :map_replacement_image_file_name
    remove_column :promotions, :map_replacement_image_content_type
    remove_column :promotions, :map_replacement_image_file_size
    remove_column :promotions, :map_replacement_image_updated_at
  end
end
