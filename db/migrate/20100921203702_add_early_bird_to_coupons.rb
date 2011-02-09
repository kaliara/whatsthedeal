class AddEarlyBirdToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :early_bird, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :early_bird
  end
end
