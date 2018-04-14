# Network (Neutron)

This document explains how to get started using OpenStack Network (Neutron) with Fog. It assumes you have read the [Getting Started with Fog and OpenStack](getting_started.md) document.

## Starting irb console

Start by executing the following command:
```
irb
```
Once `irb` has launched you need to require the Fog library by executing:
```
require 'fog/openstack'
```
## Create Service

Next, create a connection to the Network Service:
```
service = Fog::Network::OpenStack.new(
	:openstack_auth_url     => 'http://KEYSTONE_HOST:KEYSTONE_PORT/v3/auth/tokens', # OpenStack Keystone v3 endpoint
	:openstack_username     => OPEN_STACK_USER,                                     # Your OpenStack Username
	:openstack_domain_name  => OPEN_STACK_DOMAIN,                                   # Your OpenStack Domain name
	:openstack_project_name => OPEN_STACK_PROJECT,                                  # Your OpenStack Project name
	:openstack_api_key      => OPEN_STACK_PASSWORD,                                 # Your OpenStack Password
	:connection_options     => {}                                                   # Optional
)
```

Read more about the [Optional Connection Parameters](common/connection_params.md)

## Fog Abstractions

Fog provides both a **model** and **request** abstraction. The request abstraction provides the most efficient interface and the model abstraction wraps the request abstraction to provide a convenient `ActiveModel` like interface.

### Request Layer

The request abstraction maps directly to the [OpenStack Network API](http://developer.openstack.org/api-ref-networking-v2.html). It provides the most efficient interface to the OpenStack Network service.

To see a list of requests supported by the service:
```
service.requests
```

This returns:
```
:list_networks, :create_network, :delete_network, :get_network, :update_network,
:list_ports, :create_port, :delete_port, :get_port, :update_port,
:list_subnets, :create_subnet, :delete_subnet, :get_subnet, :update_subnet,
:list_floating_ips, :create_floating_ip, :delete_floating_ip, :get_floating_ip, :associate_floating_ip, :disassociate_floating_ip,
:list_routers, :create_router, :delete_router, :get_router, :update_router, :add_router_interface, :remove_router_interface,
:list_lb_pools, :create_lb_pool, :delete_lb_pool, :get_lb_pool, :get_lb_pool_stats, :update_lb_pool,
:list_lb_members, :create_lb_member, :delete_lb_member, :get_lb_member, :update_lb_member,
:list_lb_health_monitors, :create_lb_health_monitor, :delete_lb_health_monitor, :get_lb_health_monitor, :update_lb_health_monitor, :associate_lb_health_monitor, :disassociate_lb_health_monitor,
:list_lb_vips, :create_lb_vip, :delete_lb_vip, :get_lb_vip, :update_lb_vip,
:list_vpn_services, :create_vpn_service, :delete_vpn_service, :get_vpn_service, :update_vpn_service,
:list_ike_policies, :create_ike_policy, :delete_ike_policy, :get_ike_policy, :update_ike_policy,
:list_ipsec_policies, :create_ipsec_policy, :delete_ipsec_policy, :get_ipsec_policy, :update_ipsec_policy,
:list_ipsec_site_connections, :create_ipsec_site_connection, :delete_ipsec_site_connection, :get_ipsec_site_connection, :update_ipsec_site_connection,
:list_rbac_policies, :create_rbac_policy, :delete_rbac_policy, :get_rbac_policy, :update_rbac_policy,
:create_security_group, :delete_security_group, :get_security_group, :list_security_groups,
:create_security_group_rule, :delete_security_group_rule, :get_security_group_rule, :list_security_group_rules,
:set_tenant, :get_quotas, :get_quota, :update_quota, :delete_quota
```

#### Example Request

To request a list of networks:
```
response = service.list_networks
```
This returns in the following `Excon::Response`:
```
#<Excon::Response:0x007fd20d34e0e0
  @data={
    :body=>{"networks"=>[
      {"id"=>"f9c54735-a230-443e-9379-b87f741cc1b1", "name"=>"Public", "subnets"=>["db50da7f-1248-43d2-aa30-1c10da0d380d"], "shared"=>true, "status"=>"ACTIVE", "tenant_id"=>"a51fd915", "provider_network_type"=>"vlan", "router:external"=>false, "admin_state_up"=>true},
      {"id"=>"e624a36d-762b-481f-9b50-4154ceb78bbb", "name"=>"network_1", "subnets"=>["2e4ec6a4-0150-47f5-8523-e899ac03026e"], "shared"=>false, "status"=>"ACTIVE", "admin_state_up"=>true, "tenant_id"=>"f8b26a6032bc47718a7702233ac708b9"}]},
    :status=>200,
    :headers=>{}},
  @body={"networks"=>[
    {"id"=>"f9c54735-a230-443e-9379-b87f741cc1b1", "name"=>"Public", "subnets"=>["db50da7f-1248-43d2-aa30-1c10da0d380d"], "shared"=>true, "status"=>"ACTIVE", "tenant_id"=>"a51fd915", "provider_network_type"=>"vlan", "router:external"=>false, "admin_state_up"=>true},
    {"id"=>"e624a36d-762b-481f-9b50-4154ceb78bbb", "name"=>"network_1", "subnets"=>["2e4ec6a4-0150-47f5-8523-e899ac03026e"], "shared"=>false, "status"=>"ACTIVE", "admin_state_up"=>true, "tenant_id"=>"f8b26a6032bc47718a7702233ac708b9"}]},
  @headers={},
  @status=200,
  @remote_ip=nil,
  @local_port=nil,
  @local_address=nil
>
```
To view the status of the response:
```
response.status
```
**Note**: Fog is aware of valid HTTP response statuses for each request type. If an unexpected HTTP response status occurs, Fog will raise an exception.

To view response body:
```
response.body
```
This will return:
```
{"networks"=>[
  {"id"=>"f9c54735-a230-443e-9379-b87f741cc1b1", "name"=>"Public", "subnets"=>["db50da7f-1248-43d2-aa30-1c10da0d380d"], "shared"=>true, "status"=>"ACTIVE", "tenant_id"=>"a51fd915", "provider_network_type"=>"vlan", "router:external"=>false, "admin_state_up"=>true},
  {"id"=>"e624a36d-762b-481f-9b50-4154ceb78bbb", "name"=>"network_1", "subnets"=>["2e4ec6a4-0150-47f5-8523-e899ac03026e"], "shared"=>false, "status"=>"ACTIVE", "admin_state_up"=>true, "tenant_id"=>"f8b26a6032bc47718a7702233ac708b9"}]
}
```
To learn more about Network request methods refer to [rdoc](http://www.rubydoc.info/gems/fog-openstack/Fog/Network/OpenStack/Real). To learn more about Excon refer to [Excon GitHub repo](https://github.com/geemus/excon).

### Model Layer

Fog models behave in a manner similar to `ActiveModel`. Models will generally respond to `create`, `save`,  `persisted?`, `destroy`, `reload` and `attributes` methods. Additionally, fog will automatically create attribute accessors.

Here is a summary of common model methods:

<table>
	<tr>
		<th>Method</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>create</td>
		<td>
			Accepts hash of attributes and creates object.<br>
			Note: creation is a non-blocking call and you will be required to wait for a valid state before using resulting object.
		</td>
	</tr>
	<tr>
		<td>save</td>
		<td>Saves object.<br>
		Note: not all objects support updating object.</td>
	</tr>
	<tr>
		<td>persisted?</td>
		<td>Returns true if the object has been persisted.</td>
	</tr>
	<tr>
		<td>destroy</td>
		<td>
			Destroys object.<br>
			Note: this is a non-blocking call and object deletion might not be instantaneous.
		</td>
	<tr>
		<td>reload</td>
		<td>Updates object with latest state from service.</td>
	<tr>
		<td>ready?</td>
		<td>Returns true if object is in a ready state and able to perform actions. This method will raise an exception if object is in an error state.</td>
	</tr>
	<tr>
		<td>attributes</td>
		<td>Returns a hash containing the list of model attributes and values.</td>
	</tr>
		<td>identity</td>
		<td>
			Returns the identity of the object.<br>
			Note: This might not always be equal to object.id.
		</td>
	</tr>
	<tr>
		<td>wait_for</td>
		<td>This method periodically reloads model and then yields to specified block until block returns true or a timeout occurs.</td>
	</tr>
</table>

To see a list of collections supported by the service:
```
service.collections
```
This returns:
```
:networks, :ports, :subnets, :floating_ips, :routers,
:lb_pools, :lb_members, :lb_health_monitors, :lb_vips,
:vpn_services, :ike_policies, :ipsec_policies, :ipsec_site_connections,
:rbac_policies, :security_groups, :security_group_rules
```

#### Example Request

To request a collection of networks:
```
networks = service.networks
```
This returns in the following `Fog::OpenStack::Model`:
```
<Fog::Network::OpenStack::Networks
  filters={}
  [<Fog::Network::OpenStack::Network
      id="f9c54735-a230-443e-9379-b87f741cc1b1",
      name="Public",
      subnets=        <Fog::Network::OpenStack::Subnets
        filters={}
        [<Fog::Network::OpenStack::Subnet ... >]
      >,
      shared=true,
      status="ACTIVE",
      admin_state_up=true,
      tenant_id="a51fd915",
      provider_network_type="vlan",
      provider_physical_network=nil,
      provider_segmentation_id=nil,
      router_external=false
    >,
                <Fog::Network::OpenStack::Network
      id="e624a36d-762b-481f-9b50-4154ceb78bbb",
      name="network_1",
      subnets=        <Fog::Network::OpenStack::Subnets
        filters={}
        []
      >,
      shared=false,
      status="ACTIVE",
      admin_state_up=true,
      tenant_id="f8b26a6032bc47718a7702233ac708b9",
      provider_network_type=nil,
      provider_physical_network=nil,
      provider_segmentation_id=nil,
      router_external=nil
    >
  ]
>
```

To access the name of the first network:
```
networks.first.name
```
This will return:
```
"Public"
```
## Examples

Example code using Network can be found [here](https://github.com/fog/fog-openstack/tree/master/lib/fog/openstack/examples/network).

## Additional Resources

* [OpenStack Network API](http://developer.openstack.org/api-ref-networking-v2.html)
* [more resources and feedback](common/resources.md)
