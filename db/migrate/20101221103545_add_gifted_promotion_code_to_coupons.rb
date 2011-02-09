class AddGiftedPromotionCodeToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :gifted_promotion_code, :integer
  end

  def self.down
    remove_column :coupons, :gifted_promotion_code
  end
end