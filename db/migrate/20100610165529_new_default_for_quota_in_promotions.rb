class NewDefaultForQuotaInPromotions < ActiveRecord::Migration
  def self.up
    change_column_default :promotions, :quota, 0
  end

  def self.down
    change_column_default :promotions, :quota, nil
  end
end
