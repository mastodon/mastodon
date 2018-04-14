require 'fog/openstack'
require 'pp'

#
# This example sets the account quota (in bytes) for the tenant demo@test.lan
# using an admin account (admin has the reseller user role).
#
# Uses the account impersonation feature recently added to the
# OpenStack Storage service in Fog (See https://github.com/fog/fog/pull/1632).
#
# Should be available in Fog 1.10.0+1.
#
# Setting account quotas is only supported in Swift 1.8.0+
# using the brand new account_quota middleware introduced in
# OpenStack Grizzly (currently unreleased as of 2013/04/03).
#
# https://github.com/openstack/swift/blob/master/swift/common/middleware/account_quotas.py
#

auth_url = 'https://identity.test.lan/v2.0/tokens'
user = 'admin@test.lan'
password = 'secret'

Excon.defaults[:ssl_verify_peer] = false

#
# We are going to use the Identity (Keystone) service
# to retrieve the list of tenants available and find
# the tenant we want to set the quotas for.
#
id = Fog::Identity::OpenStack.new :openstack_auth_url => auth_url,
                                  :openstack_username => user,
                                  :openstack_api_key  => password

#
# Storage service (Swift)
#
st = Fog::Storage::OpenStack.new :openstack_auth_url => auth_url,
                                 :openstack_username => user,
                                 :openstack_api_key  => password

id.tenants.each do |t|
  # We want to set the account quota for tenant demo@test.lan
  next unless t.name == 'demo@test.lan'

  # We've found the tenant, impersonate the account
  # (the account prefix AUTH_ may be different for you, double check it).
  puts "Changing account to #{t.name}"
  st.change_account "AUTH_#{t.id}"

  # Now we're adding the required header to the demo@test.lan
  # tenant account, limiting the account bytes to 1048576 (1MB)
  #
  # Uploading more than 1MB will return 413: Request Entity Too Large
  st.request :method => 'POST',
             :headers => { 'X-Account-Meta-Quota-Bytes' => '1048576' }

  # We can list the account details to verify the new
  # header has been added
  pp st.request :method => 'HEAD'
end

# Restore the account we were using initially (admin@test.lan)
st.reset_account_name
