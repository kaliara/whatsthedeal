class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :item_id
      t.integer :user_id
      t.decimal :amount, :precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
