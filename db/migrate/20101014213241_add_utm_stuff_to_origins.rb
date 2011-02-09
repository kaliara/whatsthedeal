class AddUtmStuffToOrigins < ActiveRecord::Migration
  def self.up
    add_column :origins, :source, :string
    add_column :origins, :medium, :string
    add_column :origins, :campaign, :string
  end

  def self.down
    remove_column :origins, :campaign
    remove_column :origins, :medium
    remove_column :origins, :source
  end
end
