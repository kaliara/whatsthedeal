class AddSalespersonAndNationalToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :salesperson, :string, :default => "Unknown"
    add_column :promotions, :national, :boolean, :default => false
  end

  def self.down
    remove_column :promotions, :national
    remove_column :promotions, :salesperson
  end
end
