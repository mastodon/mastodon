require 'fog/openstack'

# Add additional port to an Openstack node

def create_virtual_address_pairing(username, password, auth_url, tenant, device_id, device_ip_address, network_id)
  network_driver = Fog::Network.new(:provider           => :openstack,
                                    :openstack_api_key  => password,
                                    :openstack_username => username,
                                    :openstack_auth_url => auth_url,
                                    :openstack_tenant   => tenant)

  virtual_ip_address = network_driver.create_port(network_id)

  server_nics = network_driver.list_ports('device_id' => device_id).data[:body]['ports']
  port = (server_nics.select do |network_port|
    network_port['mac_address'] == server.attributes['macaddress']
  end).first

  network_driver.update_port(port['id'], :allowed_address_pairs => [{:ip_address => device_ip_address},
                                                                    {:ip_address => virtual_ip_address}])
end
