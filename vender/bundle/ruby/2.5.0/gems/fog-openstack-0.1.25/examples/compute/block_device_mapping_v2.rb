# OpenStack Compute (Nova) Example

require 'fog/openstack'

auth_url = "https://example.net/v2.0/tokens"
username = 'admin@example.net'
password = 'secret'
tenant   = 'My Compute Tenant' # String

compute_client ||= ::Fog::Compute::OpenStack.new(
  :openstack_api_key  => password,
  :openstack_username => username,
  :openstack_auth_url => auth_url,
  :openstack_tenant   => tenant
)

_vm = compute_client.servers.create(
  :name                    => name,
  :flavor_ref              => flavor,
  :block_device_mapping_v2 => [
    {
      :boot_index            => 0,
      :device_name           => "vda",
      :source_type           => "volume", # Or "snapshot"
      :destination_type      => "volume",
      :delete_on_termination => false,
      :uuid                  => cinder_uddi,
    }
  ]
)
