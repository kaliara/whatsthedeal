class AddReadMoreTextToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :read_more_text, :string, :default => 'READ MORE'
  end

  def self.down
    remove_column :events, :read_more_text
  end
end
