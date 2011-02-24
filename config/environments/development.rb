# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = false
# config.action_mailer.delivery_method = :smtp

# setup Authorize.net gateway
# LOGIN_ID = '3JBj2tA4e4X2'
# TRANSACTION_KEY = '48k34q8A7pBuU29s'

# ActiveMerchant::Billing::Base.mode = :test

# GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new({
#   :login => LOGIN_ID, 
#   :password => TRANSACTION_KEY
# })


module ActiveMerchant
  module Utils
    def get_payment_gateway
      ActiveMerchant::Billing::Base.mode = :test
      gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        :login => '9R8h8kvZCr8w',
        :password => '9wL8fR84Vxk298RZ',
        :test => false
      )
      if not gateway
        raise AuthenticationFailed, 'Authentication with CIM Gateway could not be completed.'
      end
      return gateway
    end
  end
end

# spreadsheet
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'

# globals
HOST_URL = "http://localhost:3000/"
HOST_DOMAIN = "localhost:3000/"