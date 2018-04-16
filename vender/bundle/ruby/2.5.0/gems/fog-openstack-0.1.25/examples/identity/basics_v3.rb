# OpenStack Identity Service (Keystone) Example

require 'fog/openstack'
require 'pp'

auth_url = "https://example.net:35357/v3/auth/tokens"
username = 'admin@example.net'
password = 'secret'
project = 'admin'
domain = 'Default'



keystone = Fog::Identity::OpenStack.new :openstack_auth_url => auth_url,
                                        :openstack_username => username,
                                        :openstack_api_key  => password,
                                        :openstack_project_name => project,
                                        :openstack_domain_name => domain
                                        # Optional, self-signed certs
                                        #:connection_options => { :ssl_verify_peer => false }

#
# List keystone projects
#
keystone.projects.each do |project|
  #<Fog::Identity::OpenStack::V3::Project
  #  id="17775c",
  #  domain_id="default",
  #  description="admin tenant",
  #  enabled=true,
  #  name="admin",
  #  links={"self"=>"http://example.net:35357/..."},
  #  parent_id=nil,
  #  subtree=nil,
  #  parents=nil
  #>
  # ...
  pp project
end

#
# List users
#
keystone.users.each do |user|
  #<Fog::Identity::OpenStack::V3::User
  #  id="02124b...",
  #  default_project_id=2f534e...,
  #  description=nil,
  #  domain_id="default",
  #  email="quantum@example.net",
  #  enabled=true,
  #  name="quantum",
  #  links={"self"=>"http://example.net:35357/..."},
  #  password=nil
  #>
  # ...
  pp user
end

#
# Create a new tenant
#
project = keystone.projects.create :name        => 'rubiojr@example.net',
                                   :description => 'My foo tenant'

#
# Create a new user
#
user = keystone.users.create :name               => 'rubiojr@example.net',
                             :default_project_id => project.id,
                             :password           => 'rubiojr@example.net',
                             :email              => 'rubiojr@example.net',
                             :domain_id          => 'Default'

# Find the recently created tenant
project = keystone.projects.find { |t| t.name == 'rubiojr@example.net' }
# Destroy the tenant
project.destroy

# Find the recently created user
user = keystone.users.find { |u| u.name == 'rubiojr@example.net' }
# Destroy the user
user.destroy
