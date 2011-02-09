class CreatePromotionCodes < ActiveRecord::Migration
  def self.up
    create_table :promotion_codes do |t|
      t.string :code
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :promotion_codes
  end
end
