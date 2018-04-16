# NFV

This document explains how to get started using NFV with
fog-openstack.

Please also refer to the
[Getting Started with Fog and the OpenStack](getting_started.md) document.

Tacker is an OpenStack service for NFV Orchestration with a general purpose
VNF Manager to deploy and operate Virtual Network Functions (VNFs) and Network
Services on an NFV Platform. It is based on ETSI MANO Architectural Framework.

# OpenStack setup

## The catalog
For the fog-openstack's introspection service to work, the corresponding
service must be defined in the OpenStack catalog.

```bash
openstack catalog show servicevm
+-----------+-----------------------------------------+
| Field     | Value                                   |
+-----------+-----------------------------------------+
| endpoints | regionOne                               |
|           |   publicURL: http://172.16.0.21:8888/   |
|           |   internalURL: http://172.16.0.21:8888/ |
|           |   adminURL: http://172.16.0.21:8888/    |
|           |                                         |
| name      | tacker                                  |
| type      | servicevm                               |
+-----------+-----------------------------------------+
```

Depending on the OpenStack release, the NFV service might be installed
but not defined yet in the catalog. In such case, you must add the service and
corresponding endpoints to create the catalog entry:

```bash
source ./stackrc
openstack service create --name tacker --description "Tacker Project" servicevm
openstack endpoint create --region regionOne tacker --publicurl http://example.com:8888 --internalurl http://example.com:8888 --adminurl http://example.com:8888
```

# Work flow
A usual work-flow might consist of:
* Create vnfd
* Deploy vnf using vnfd
* Retrieve vnf and vnfd data

For more details please refer to
http://docs.openstack.org/developer/tacker/

Using 'irb', we start with authentication:

```ruby
@user     = "admin"
@project  = "admin"
@password = "secret"
@base_url = "http://keystone.example.com:5000/v3/auth/tokens"

require 'rubygems'
require 'fog/openstack'

@connection_params = {
  :openstack_auth_url     => @base_url,
  :openstack_username     => @user,
  :openstack_api_key      => @password,
  :openstack_project_name => @project,
  :openstack_domain_id    => "default"
}
```

## Vnfd management

### Create vnfd

```ruby
vnfd_data = {:attributes    => {:vnfd => "template_name: sample-vnfd\ndescription: demo-example\n\nservice_properties:\n  Id: sample-vnfd\n  vendor: tacker\n  version: 1\n\nvdus:\n  vdu1:\n    id: vdu1\n    vm_image: cirros\n    instance_type: m1.tiny\n\n    network_interfaces:\n      management:\n        network: net_mgmt\n        management: true\n      pkt_in:\n        network: net0\n      pkt_out:\n        network: net1\n\n    placement_policy:\n      availability_zone: nova\n\n    auto-scaling: noop\n\n    config:\n      param0: key0\n      param1: key1\n"},
             :service_types => [{:service_type => "vnfd"}],
             :mgmt_driver   => "noop",
             :infra_driver  => "heat"}
auth      = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin","password" => "password"}}
vnfd      = Fog::NFV[:openstack].vnfds.create(:vnfd => vnfd_data, :auth => auth)
```

### List vnfds

```ruby
vnfds = Fog::NFV[:openstack].vnfds
```

### Get vnfd

```ruby
vnfd = Fog::NFV[:openstack].vnfds.last
vnfd = Fog::NFV[:openstack].vnfds.get(vnfd.id)
```

### Destroy vnfd

```ruby
vnfd = Fog::NFV[:openstack].vnfds.last
vnfd.destroy
```

## Vnf management

### Create vnf using vnfd

```ruby
vnfd     = Fog::NFV[:openstack].vnfds.last
vnf_data = {:vnfd_id => vnfd.id, :name => 'Test'}
auth     = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin","password" => "password"}}
vnf      = Fog::NFV[:openstack].vnfs.create(:vnf => vnf_data, :auth => auth)
```

### List vnfs

```ruby
vnfs = Fog::NFV[:openstack].vnfs
```

### Get vnf

```ruby
vnf = Fog::NFV[:openstack].vnfs.last
vnf = Fog::NFV[:openstack].vnfs.get(vnf.id)
```

### Update vnf

```ruby
vnf      = Fog::NFV[:openstack].vnfs.last
vnf_data = {"attributes": {"config": "vdus:\n  vdu1:<sample_vdu_config> \n\n"}}
auth     = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin","password" => "password"}}
vnf      = vnf.update(:vnf => vnf_data, :auth => auth)
```

### Destroy vnf

```ruby
vnf = Fog::NFV[:openstack].vnfs.last
vnf.destroy
```
