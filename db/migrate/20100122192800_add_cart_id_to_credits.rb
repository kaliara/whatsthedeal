class AddCartIdToCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :cart_id, :integer
  end

  def self.down
    remove_column :credits, :cart_id
  end
end
