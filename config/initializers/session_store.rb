# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
#ActionController::Base.session = {
#   :key         => '_bbs_session',
#   :secret      => '9240c496829bed639a368a4708ae4505a2d961ea3a58d7aac809389eb97958de8cafc5a61a13b97a0c4938ab011ef327c3e2a5028db846375702dd6a85cdd0db',
#   :cookie_only => false,
#   :memcache_server => 'localhost:11211',#['localhost:11211','192.168.0.202:11211'],
#   :expire_after => 1800,#expire１日86400
#   :namespace => "bbs-#{RAILS_ENV}",
#}
#ActionController::Base.session_store = :mem_cache_store
ActionController::Base.session = {
   :key         => '_bbs_session',
   :secret      => '9240c496829bed639a368a4708ae4505a2d961ea3a58d7aac809389eb97958de8cafc5a61a13b97a0c4938ab011ef327c3e2a5028db846375702dd6a85cdd0db',
   :cookie_only => false,
   :expire_after => 1800,#expire１日86400
}
ActionController::Base.session_store = :active_record_store

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
