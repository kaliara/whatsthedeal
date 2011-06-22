class AddAdditionalFieldsToKgbVouchers < ActiveRecord::Migration
  def self.up
    add_column :kgb_coupons, :voucher_index, :integer
    add_column :kgb_coupons, :voucher_alphanum, :string
    add_column :kgb_coupons, :voucher_full_id, :string
    add_column :kgb_coupons, :voucher_user_id, :integer
    add_column :kgb_coupons, :voucher_status, :string
    add_column :kgb_coupons, :voucher_timestamp, :datetime
  end

  def self.down
    remove_column :kgb_coupons, :voucher_timestamp
    remove_column :kgb_coupons, :voucher_status
    remove_column :kgb_coupons, :voucher_user_id
    remove_column :kgb_coupons, :voucher_full_id
    remove_column :kgb_coupons, :voucher_alphanum
    remove_column :kgb_coupons, :voucher_index
  end
end
