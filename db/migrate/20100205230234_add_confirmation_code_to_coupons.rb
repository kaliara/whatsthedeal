class AddConfirmationCodeToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :confirmation_code, :string
  end

  def self.down
    remove_column :coupons, :confirmation_code
  end
end
