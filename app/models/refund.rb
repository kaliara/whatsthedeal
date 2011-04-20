class Refund < ActiveRecord::Base
  belongs_to :credit
  belongs_to :purchase
  
  validates_presence_of :purchase_id, :on => :create, :message => "can't be blank"
end
