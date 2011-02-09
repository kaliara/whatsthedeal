class Customer < ActiveRecord::Base
  STOCK_FIRST_NAME = '[no first name]'
  STOCK_LAST_NAME = '[no last name]'
  INCOME_RANGES = [['0-10K',1], ['10K-25K',2], ['25K-50K',3], ['50K-100k',4], ['100K+',5]]
  EMPLOYMENT_STATUSES = [['Part-Timer',1], ['Full-Timer',2], ['Between Jobs',3], ['Retired',4]]
  STATES = [[ "Alabama", "AL" ], [ "Alaska", "AK" ], [ "Arizona", "AZ" ], [ "Arkansas", "AR" ], [ "California", "CA" ], [ "Colorado", "CO" ], [ "Connecticut", "CT" ], [ "Delaware", "DE" ], [ "District Of Columbia", "DC" ], [ "Florida", "FL" ], [ "Georgia", "GA" ], [ "Hawaii", "HI" ], [ "Idaho", "ID" ], [ "Illinois", "IL" ], [ "Indiana", "IN" ], [ "Iowa", "IA" ], [ "Kansas", "KS" ], [ "Kentucky", "KY" ], [ "Louisiana", "LA" ], [ "Maine", "ME" ], [ "Maryland", "MD" ], [ "Massachusetts", "MA" ], [ "Michigan", "MI" ], [ "Minnesota", "MN" ], [ "Mississippi", "MS" ], [ "Missouri", "MO" ], [ "Montana", "MT" ], [ "Nebraska", "NE" ], [ "Nevada", "NV" ], [ "New Hampshire", "NH" ], [ "New Jersey", "NJ" ], [ "New Mexico", "NM" ], [ "New York", "NY" ], [ "North Carolina", "NC" ], [ "North Dakota", "ND" ], [ "Ohio", "OH" ], [ "Oklahoma", "OK" ], [ "Oregon", "OR" ], [ "Pennsylvania", "PA" ], [ "Rhode Island", "RI" ], [ "South Carolina", "SC" ], [ "South Dakota", "SD" ], [ "Tennessee", "TN" ], [ "Texas", "TX" ], [ "Utah", "UT" ], [ "Vermont", "VT" ], [ "Virginia", "VA" ], [ "Washington", "WA" ], [ "West Virginia", "WV" ], [ "Wisconsin", "WI" ], [ "Wyoming", "WY" ]]

  belongs_to :user
  
  validates_presence_of :first_name, :on => :save, :message => "can't be blank"
  validates_presence_of :last_name, :on => :save, :message => "can't be blank"
  # validates_presence_of :zipcode, :on => :create, :message => "can't be blank", :unless => proc { |customer| customer.quietly_created? }
  
  # validates_each :female, :on => :create do |record, attr, value|
  #   record.errors.add :gender, 'should be chosen' if !record.quietly_created? and record.female.nil?
  # end
  
  def name
    (self.first_name == Customer::STOCK_FIRST_NAME ? "" : self.first_name) + " " + (self.last_name == Customer::STOCK_LAST_NAME ? "" : self.last_name)
  end
  
  def has_name?
    self.first_name != Customer::STOCK_FIRST_NAME and !self.first_name.blank? and self.last_name != Customer::STOCK_LAST_NAME and !self.last_name.blank?
  end
  
  def has_billing_address?
    !(self.billing_street1.blank? or self.billing_city.blank? or self.billing_state.blank?)
  end

  def has_shipping_address?
    !(self.shipping_street1.blank? or self.shipping_city.blank? or self.shipping_state.blank?)
  end
end