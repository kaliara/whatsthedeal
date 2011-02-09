class RedoCreditsTable < ActiveRecord::Migration
  def self.up
    remove_column :credits, :name
    remove_column :credits, :code
    remove_column :credits, :use_limit
    add_column :credits, :purchase_id, :integer
  end

  def self.down
    remove_column :credits, :purchase_id
    add_column :credits, :use_limit, :integer
    add_column :credits, :code, :string
    add_column :credits, :name, :string
  end
end
