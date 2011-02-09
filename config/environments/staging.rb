# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :smtp

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!


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
HOST_URL = "http://staging.sowhatsthedeal.com/"
HOST_DOMAIN = "staging.sowhatsthedeal.com/"