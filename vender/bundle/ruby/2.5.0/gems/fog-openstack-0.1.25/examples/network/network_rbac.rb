require 'fog/openstack'
require 'pp'

#
# Creates a private network and shares it with another project via RBAC policy
#
# Needs to be in an environment where keystone v3 is available
#
# You will need to source OpenStack credentials since the script
# reads the following envionment variables:
#
#  OS_AUTH_URL
#  OS_PASSWORD
#  OS_USERNAME
#  OS_USER_DOMAIN_NAME
#  OS_PROJECT_NAME
#  OS_REGION_NAME
#
#  optionally disable SSL verification
#  SSL_VERIFY=false

auth_options = {
  :openstack_auth_url     => "#{ENV['OS_AUTH_URL']}/auth/tokens",
  :openstack_api_key      => ENV['OS_PASSWORD'],
  :openstack_username     => ENV['OS_USERNAME'],
  :openstack_domain_name  => ENV['OS_USER_DOMAIN_NAME'],
  :openstack_project_name => ENV['OS_PROJECT_NAME'],
  :openstack_region       => ENV['OS_REGION_NAME'],
  :connection_options     => {:ssl_verify_peer => ENV['SSL_VERIFY'] != 'false'}
}

identity_service = Fog::Identity::OpenStack::V3.new(auth_options)
network_service  = Fog::Network::OpenStack.new(auth_options)

own_project   = identity_service.projects.select { |p| p.name == ENV['OS_PROJECT_NAME'] }.first
other_project = identity_service.projects.select { |p| p.name != ENV['OS_PROJECT_NAME'] }.first

puts "Create network in #{own_project.name}"
foonet = network_service.networks.create(:name => 'foo-net23', :tenant_id => own_project.id)

puts "Share network with #{other_project.name}"
rbac = network_service.rbac_policies.create(
  :object_type   => 'network',
  :object_id     => foonet.id,
  :tenant_id     => own_project.id,
  :target_tenant => other_project.id,
  :action        => 'access_as_shared'
)

puts "Get RBAC policy"
rbac = network_service.rbac_policies.find_by_id(rbac.id)
pp rbac

puts "Change share to own project"
rbac.target_tenant = own_project.id
rbac.save

puts "Get network and see that it is now shared"
foonet = network_service.networks.get(foonet.id)
pp foonet

puts "Remove the share via RBAC"
rbac.destroy

puts "Get network and see that it is no longer shared"
foonet.reload
pp foonet

foonet.destroy
