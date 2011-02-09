# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails2_session',
  :secret      => 'f7ee659b32ed0789b6315462e44dafb48592feb24b4da1a32aff0a66d8ce057972f8b040a37ecbd2cdec2e7816697a0c80241d18ab8c3342f30126ef37080fbf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
