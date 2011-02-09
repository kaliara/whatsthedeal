class AddPageImageToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :page_image, :string
  end

  def self.down
    remove_column :events, :page_image
  end
end
