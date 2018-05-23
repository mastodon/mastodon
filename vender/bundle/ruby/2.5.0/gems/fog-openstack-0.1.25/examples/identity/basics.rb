# OpenStack Identity Service (Keystone) Example

require 'fog/openstack'
require 'pp'

auth_url = "https://example.net/v2.0/tokens"
username = 'admin@example.net'
password = 'secret'

keystone = Fog::Identity::OpenStack.new :openstack_auth_url => auth_url,
                                        :openstack_username => username,
                                        :openstack_api_key  => password
                                        # Optional, self-signed certs
                                        #:connection_options => { :ssl_verify_peer => false }

#
# Listing keystone tenants
#
keystone.tenants.each do |tenant|
  # <Fog::Identity::OpenStack::Tenant
  #   id="46b4ab...",
  #   description=nil,
  #   enabled=1,
  #   name="admin@example.net"
  # >
  pp tenant
end

#
# List users
#
keystone.users.each do |user|
  # <Fog::Identity::OpenStack::User
  #   id="c975f...",
  #   email="quantum@example.net",
  #   enabled=true,
  #   name="quantum",
  #   tenant_id="00928...",
  #   password=nil
  # >
  # ...
  pp user
end

#
# Create a new tenant
#
tenant = keystone.tenants.create :name        => 'rubiojr@example.net',
                                 :description => 'My foo tenant'

#
# Create a new user
#
user = keystone.users.create :name      => 'rubiojr@example.net',
                             :tenant_id => tenant.id,
                             :password  => 'rubiojr@example.net',
                             :email     => 'rubiojr@example.net'

# Find the recently created tenant
tenant = keystone.tenants.find { |t| t.name == 'rubiojr@example.net' }
# Destroy the tenant
tenant.destroy

# Find the recently created user
user = keystone.users.find { |u| u.name == 'rubiojr@example.net' }
# Destroy the user
user.destroy
