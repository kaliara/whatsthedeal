class AddDemographicsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :number_of_kids, :integer
    add_column :customers, :employment_status, :integer
    add_column :customers, :employment_zipcode, :string
    add_column :customers, :annual_income, :integer
  end

  def self.down
    remove_column :customers, :annual_income
    remove_column :customers, :employment_zipcode
    remove_column :customers, :employment_status
    remove_column :customers, :number_of_kids
  end
end
