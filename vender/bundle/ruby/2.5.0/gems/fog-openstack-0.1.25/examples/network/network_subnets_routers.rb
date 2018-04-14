require 'fog/openstack'

#
# Quantum demo
#
# Create some routers, networks and subnets for
# a couple of tenants.
#
# Needs Fog >= 1.11.0
# Needs OpenStack credentials in ~/.fog
#

def create_tenant_network( tenant_name,
                           external_net,
                           router_name = 'router1',
                           subnet_range = '10.0.0.0/21',
                           subnet_gateway = '10.0.0.1',
                           private_network_name = 'private' )

  network = Fog::Network[:openstack]
  id = Fog::Identity[:openstack]

  tenant = id.tenants.find { |t| t.name == tenant_name }

  # Create a router for the tenant
  router = network.routers.create :name => router_name,
                                  :tenant_id => tenant.id,
                                  :external_gateway_info => {
                                    'network_id' => external_net.id
                                  }

  # Create a private network for the tenant
  net = network.networks.create :name => private_network_name,
                                :tenant_id => tenant.id

  # Create a subnet for the previous network and associate it
  # with the tenant
  subnet = network.subnets.create :name => 'net_10',
                                  :network_id  => net.id,
                                  :ip_version  => 4,
                                  :gateway_ip  => subnet_gateway,
                                  :cidr        => subnet_range,
                                  :tenant_id => tenant.id,
                                  :enable_dhcp => true

  network.add_router_interface router.id, subnet.id
end

# Create a public shared network
public_net = network.networks.create :name => 'nova',
                                     :router_external => true

# Create the public subnet
public_subnet = network.subnets.create :name => 'floating_ips_net',
                                       :network_id  => public_net.id,
                                       :ip_version  => 4,
                                       :cidr        => '1.2.3.0/24',
                                       :enable_dhcp => false

# Create tenant networks
create_tenant_network 'admin@example.net', public_net
create_tenant_network 'demo@example.net', public_net
