# 1.10.1 2013/04/04

## Storage

* Added storage (Swift) example to set account quotas:

  https://github.com/fog/fog/blob/master/lib/fog/openstack/examples/storage/set-account-quota.rb

* Added account impersonation to the storage service

  Now it's possible to use an admin account with a reseller
  role to impersonate other accounts and set account metadata
  headers. See the account quotas example included in this release

## Network

* create_network request updated

  Implements provider extensions when creating networks.

  See http://docs.openstack.org/trunk/openstack-network/admin/content/provider_attributes.html

* Network Router support (Quantum)

  Added router model/collection and related requests.

* New network service example

  See https://github.com/fog/fog/blob/master/lib/fog/openstack/examples/network/network_subnets_routers.rb

* :openstack_endpoint_type parameter was added to the network service

## Image

* Added basic image service example (Glance)

  Download CirrOS 0.3.0 image from launchpad (~6.5MB) to /tmp
  and upload it to Glance.

  See https://github.com/fog/fog/blob/master/lib/fog/openstack/examples/image/upload-test-image.rb

* Check for glance version (fog only supports v1)

## Compute

* create_server and the Server model where updated to allow booting a VM
  with NICs (net_id, port_id, fixed_ip).
