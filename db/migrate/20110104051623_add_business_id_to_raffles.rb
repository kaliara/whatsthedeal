class AddBusinessIdToRaffles < ActiveRecord::Migration
  def self.up
    add_column :raffles, :business_id, :integer
  end

  def self.down
    remove_column :raffles, :business_id
  end
end