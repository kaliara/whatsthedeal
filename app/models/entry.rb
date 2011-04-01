class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :raffle

  validates_uniqueness_of :user_id, :scope => :raffle_id, :on => :create, :message => "must be unique"
end
