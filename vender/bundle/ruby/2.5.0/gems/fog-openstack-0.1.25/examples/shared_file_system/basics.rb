require 'fog/openstack'
require 'pp'

#
# Creates a share network and a share
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

network_service = Fog::Network::OpenStack.new(auth_options)
share_service   = Fog::SharedFileSystem::OpenStack.new(auth_options)

net = network_service.networks.first
raise 'no network exists' if net.nil?

puts "Create share network in #{net.name}"
share_network = share_service.networks.create(
  :neutron_net_id    => net.id,
  :neutron_subnet_id => net.subnets.first.id,
  :name              => 'fog_share_net'
)

pp share_network

puts 'Create share'
example_share = share_service.shares.create(
  :share_proto      => 'NFS',
  :size             => 1,
  :name             => 'fog_share',
  :share_network_id => share_network.id
)

pp example_share

puts 'Create snapshot'
example_snap = share_service.snapshots.create(
  :share_id => example_share.id,
  :name     => 'fog_share_snapshot'
)

pp example_snap

puts 'Removing snapshot, share and share network'
example_snap.destroy
example_share.destroy
share_network.destroy
