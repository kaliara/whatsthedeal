class AddStartDateToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :start_date, :datetime
  end

  def self.down
    remove_column :promotions, :start_date
  end
end
