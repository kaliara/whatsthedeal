class AddPregeneratedCodesToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :pregenerated_codes, :boolean, :default => false
  end

  def self.down
    remove_column :deals, :pregenerated
  end
end