
require 'rubygems'
require 'fog/openstack' # version >= 1.37

auth_url = "https://example.net:5000/v3/auth/tokens"
username = 'admin@example.net'
password = 'secret'
project  = 'admin'

@connection_params = {
  :openstack_auth_url     => auth_url,
  :openstack_username     => username,
  :openstack_api_key      => password,
  :openstack_project_name => project,
  :openstack_domain_id    => "default"
}

inspector = Fog::Introspection::OpenStack.new(@connection_params)

# Introspection of an Ironic node
ironic = Fog::Baremetal::OpenStack.new(@connection_params)
nodes = ironic.list_nodes
node1_uuid = nodes.body["nodes"][0]["uuid"]

# Launch introspection
inspector.create_introspection(node1_uuid)

# Introspection status
inspector.get_introspection(node1_uuid)

# Abort introspection
inspector.abort_introspection(node1_uuid)

# Retrieve introspection data
# Note: introspection must be finished and ended successfully
inspector.get_introspection_details(node1_uuid)

## Introspection Rules
# Create a set of rules
rules = {
  "description" => "Successful Rule",
  "actions"     => [
    {
      "action" => "set-attribute",
      "path"   => "/extra/rule_success",
      "value"  => "yes"
    }
  ],
  "conditions"  => [
    {
      "field" => "memory_mb",
      "op"    => "ge",
      "value" => 256
    },
    {
      "field" => "local_gb",
      "op"    => "ge",
      "value" => 1
    }
  ]
}
inspector.create_rules(rules)

# List all rules set
rules1 = inspector.list_rules

# Show a rules set
rules1_uuid = rules1[:body]["rules"][0]['uuid']
inspector.get_rules(rules1_uuid)

# Delete a specific rules set
inspector.delete_rules(rules1_uuid)

# Destroys all rules sets
inspector.delete_rules_all
