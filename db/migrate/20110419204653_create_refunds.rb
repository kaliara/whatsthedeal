class CreateRefunds < ActiveRecord::Migration
  def self.up
    create_table :refunds do |t|
      t.integer :purchase_id
      t.integer :credit_id
      t.decimal :cc_amount, :default => 0, :precision => 10, :scale => 2
      t.decimal :credit_amount, :default => 0, :precision => 10, :scale => 2
      t.text :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :refunds
  end
end
