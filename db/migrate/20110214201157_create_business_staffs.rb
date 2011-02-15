class CreateBusinessStaffs < ActiveRecord::Migration
  def self.up
    create_table :business_staffs do |t|
      t.integer :user_id
      t.integer :business_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :business_staffs
  end
end
