class AddImpersonationIdsToAdmin < ActiveRecord::Migration
  def self.up
    add_column :admins, :business_impersonation_id, :integer, :default => 19
    add_column :admins, :customer_impersonation_id, :integer, :default => 57
  end

  def self.down
    remove_column :admins, :customer_impersonation_id
    remove_column :admins, :business_impersonation_id
  end
end
