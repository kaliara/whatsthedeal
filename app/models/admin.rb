class Admin < ActiveRecord::Base
  belongs_to :user
  
  LIZ = 9
end