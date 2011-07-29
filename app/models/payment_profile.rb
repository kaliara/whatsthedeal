class PaymentProfile < ActiveRecord::Base
  include ActiveMerchant::Utils
  
  belongs_to :user
  has_many :purchases

  validates_presence_of :billing_address, :on => :create, :message => "can't be blank"

  attr_accessor :billing_address
  attr_accessor :credit_card

  #accepts_nested_attributes_for :credit_card, :allow_destroy => false, :reject_if => proc { |obj| obj.blank? }

  # NOTE: overrides traditional CRUD methods 
  # since we only act on this model in conjuction with CIM
  
  def create
    if super and create_payment_profile
      # user.update_attributes({:payment_profile_id => self.id})
      return true
    else
      if self.id
        #destroy the instance if it was created
        #self.destroy
      end
      return false
    end
  end

  #def update
    #if super and update_payment_profile
   #   return true
    #end
    #return false
  #end

  def destroy
    if delete_payment_profile and super
      return true
    else
      return false
    end
  end

  private
  def get_payment_profile
    @gateway = get_payment_gateway
    @profile = {:customer_profile_id => User.find(self.user_id).customer_cim_id,
                :customer_payment_profile_id => self.payment_cim_id}
                
    response = @gateway.get_customer_payment_profile(@profile)
    
    if response.success?
      return response.params['payment_profile']
    else
      return nil
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def create_payment_profile
    @gateway = get_payment_gateway
    @profile = {:customer_profile_id => User.find(self.user_id).customer_cim_id,
                :payment_profile => {:bill_to => self.billing_address,
                                     :payment => {:credit_card => ActiveMerchant::Billing::CreditCard.new(self.credit_card)}
                                     }
                }

    if duplicate_payment_profile?(@profile)
      errors.add(:profile, 'This payment information has been used already. Please contact support@sowhatsthedeal.com if you believe this message has appeared in error.')
      return false
    elsif credit_card[:number].blank? or credit_card[:number].size < 15 or credit_card[:number].size > 16
      errors.add(:profile, 'Please check your <strong>Credit Card Number</strong>, it should be 15 (American Express) or 16 (MasterCard and Visa) digits long')
      return false
    # elsif credit_card[:verification_value].size < 3 or credit_card[:verification_value].size > 4
    #   errors.add(:profile, 'Please check your <strong>Card Verification Value</strong>.  It should be 3 or 4 digits long and can be found on the front (American Express) or back (MasterCard and Visa) of  your credit card.')
    #   return false
    elsif credit_card[:first_name].blank? or credit_card[:last_name].blank?
      errors.add(:profile, 'Please fill in the <strong>First and Last Name</strong> that appears on your credit card.')
      return false
    elsif billing_address[:address1].blank?
      errors.add(:profile, 'Please fill in your <strong>Billing Address</strong>.')
      return false
    elsif billing_address[:zip].blank? or billing_address[:zip].size < 5
      errors.add(:profile, 'Please check your <strong>Billing Zip Code</strong>.  It should be at least 5 digits long.')
      return false
    end

    response = @gateway.create_customer_payment_profile(@profile)
    
    if response.success? and response.params['customer_payment_profile_id']
      update_attributes({:payment_cim_id => response.params['customer_payment_profile_id']})
      self.billing_cc_last_four = @profile[:payment_profile][:payment][:credit_card].number[-4..-1]
      self.billing_address1     = @profile[:payment_profile][:bill_to][:address]
      self.billing_city         = @profile[:payment_profile][:bill_to][:city]
      self.billing_state        = @profile[:payment_profile][:bill_to][:state]
      self.billing_zip          = @profile[:payment_profile][:bill_to][:zip]
      self.billing_first_name   = @profile[:payment_profile][:bill_to][:first_name]
      self.billing_last_name    = @profile[:payment_profile][:bill_to][:last_name]
      self.save
      return true
    else
      return false
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end

  def update_payment_profile
    @gateway = get_payment_gateway

    @profile = {:customer_profile_id => self.user.customer_cim_id,
                :payment_profile => {:customer_payment_profile_id => self.payment_cim_id,
                                     :bill_to => self.billing_address,
                                     :payment => {:credit_card => ActiveMerchant::Billing::CreditCard.new(self.credit_card)}
                                     }
                }
    response = @gateway.update_customer_payment_profile(@profile)

    if response.success?
      self.billing_address = {}
      self.credit_card = {}
      return true
    else
      return false
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end

  def delete_payment_profile
    @gateway = get_payment_gateway

    response = @gateway.delete_customer_payment_profile(:customer_profile_id => self.user.customer_cim_id,
                                                        :customer_payment_profile_id => self.payment_cim_id)
    if response.success?
      return true
    else
      false
    end
  rescue ActiveMerchant::ConnectionError => e
  	errors.add_to_base "Sorry, one of the interns tripped over a cord (there was a timeout error). <br/><br/><strong>If you were in the middle of a purchase</strong>, check your account to see if your deal is in your account. If not, try again in a minute or two. <br/><br/>Need us to check on something? Email us at support@sowhatsthedeal.com"
  end
  
  def duplicate_payment_profile?(profile)
    return false if profile[:payment_profile][:payment][:credit_card].number.nil?
    PaymentProfile.find(:all, :conditions => {
      :billing_cc_last_four => profile[:payment_profile][:payment][:credit_card].number[-4..-1],
     #:billing_cc_year      => profile[:payment_profile][:payment][:credit_card].year, # had to take this out since auth.net won't provide it in the getPaymentProfile 
      :billing_zip          => profile[:payment_profile][:bill_to][:zip],
      :billing_last_name    => profile[:payment_profile][:bill_to][:last_name]
    }).size > 0
  end
end
