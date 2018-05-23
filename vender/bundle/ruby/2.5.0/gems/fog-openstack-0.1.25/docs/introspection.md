# Introspection

This document explains how to get started using introspection with
fog-openstack.

Please also refer to the
[Getting Started with Fog and the OpenStack](getting_started.md) document.

Introspection service is implemented by the OpenStack ironic-inspector project.
Introspection is strongly related to the Baremetal service (Ironic project).
Effectively, Instrospection communicates and operates on nodes defined by the
Baremetal layer (Ironic).

# OpenStack setup

## The catalog
For the fog-openstack's introspection service to work, the corresponding
service must be defined in the OpenStack catalog.

```bash
openstack catalog show inspector
+-----------+-----------------------------------------+
| Field     | Value                                   |
+-----------+-----------------------------------------+
| endpoints | regionOne                               |
|           |   publicURL: http://192.0.2.1:5050/v1   |
|           |   internalURL: http://192.0.2.1:5050/v1 |
|           |   adminURL: http://192.0.2.1:5050/v1    |
|           |                                         |
| name      | inspector                               |
| type      | introspection                           |
+-----------+-----------------------------------------+
```

Depending on the OpenStack release, the introspection service might be installed
but not defined yet in the catalog. In such case, you must add the service and
corresponding endpoints to create the catalog entry:

```bash
source ./stackrc
openstack service create --name inspector --description "OpenStack Introspection" introspection
openstack endpoint create --region regionOne inspector --publicurl http://example.com:5050/v1 --internalurl http://example.com:5050/v1 --adminurl http://example.com:5050/v1
```

## The introspection timeout
The default timeout value after which introspection is considered failed is set
by an 1 hour (3600 s) default. Although in production environment, baremetal
introspection requires time, testing in virtual environment doesn't, this is why
if you are in the latter case the timeout value can be reduced for speeding
results:

```bash
sudo openstack-config --set /etc/ironic-inspector/inspector.conf DEFAULT timeout 300
```

# Work flow
Assuming Baremetal nodes have been defined (imported), a usual work-flow might
consist of:
* Start introspection
* Check introspection status or abort introspection
* Retrieve introspection data
* optionally, pre-defined DSL based rules can be defined and applied during
  introspection.

For more details about this process please refer to
http://docs.openstack.org/developer/ironic-inspector/workflow.html


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
## Baremetal node introspection

### Baremetal nodes

Find the available Baremetal nodes.

```ruby
iron = Fog::Baremetal::OpenStack.new(@connection_params)

nodes = iron.node_list
```

### Start introspection

Let's start introspection using the first available node.

Note: To be introspected, a node must be in "manage" state. If needed, use Baremetal Service
to change the state with set_node_provision_state.

For more information, please refer to
http://docs.openstack.org/developer/ironic/deploy/install-guide.html#hardware-inspection

```ruby
node_id = nodes.body["nodes"][0]["uuid"]
inspector = Fog::Introspection::OpenStack.new(@connection_params)

introspection1 = inspector.create_introspection(node_id)
```
If everything went well the status returned by the request must be 202 which
means accepted:
```ruby
introspection1.status
=> 202
```

### Check introspection status

To check the status of the introspection:
```ruby
inspector.get_introspection(node_id)
```

The body returned has 2 fields:
* finished: A boolean, set to true if introspection process is finished
* error: A null string unless an error occurred or the process was canceled by
  the operator (in case introspection was aborted)

### Abort an ongoing introspection

To abort a node introspection:
```ruby
inspector.abort_introspection(node_id)
```

### Retrieve introspected data

```ruby
inspector.get_introspection_details(node_id)
```
The response body will provide a *very* long list of information about the node.

## DSL rules

### Create rules

```ruby
rule_set1 = {
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

rule_set2 = {
  "description" => "Failing Rule",
  "actions"     => [
    {
      "action" => "set-attribute",
      "path"   => "/extra/rule_success",
      "value"  => "no"
    },
    {
      "action"  => "fail",
      "message" => "This rule should not have run"
    }
  ],
  "conditions"  => [
    {
      "field" => "memory_mb",
      "op"    => "lt",
      "value" => 42
    },
    {
      "field" => "local_gb",
      "op"    => "eq",
      "value" => 0
    }
  ],
}

inspector.create_rules(rule_set1)
inspector.create_rules(rule_set2)
```

### List all rules

```ruby
inspector.list_rules.body
=> {"rules"=>
  [{"description"=>"Successful Rule",
    "links"=>[{"href"=>"/v1/rules/4bf1bf40-d30f-4f31-a970-f0290d7e751b", "rel"=>"self"}],
    "uuid"=>"4bf1bf40-d30f-4f31-a970-f0290d7e751b"},
   {"description"=>"Failing Rule",
    "links"=>[{"href"=>"/v1/rules/0d6e6687-3f69-4c14-8cab-ea6ada78036f", "rel"=>"self"}],
    "uuid"=>"0d6e6687-3f69-4c14-8cab-ea6ada78036f"}]}
```

### Show rules details

```ruby
inspector.get_rules('0d6e6687-3f69-4c14-8cab-ea6ada78036f').body
=> {"actions"=>
  [{"action"=>"set-attribute", "path"=>"/extra/rule_success", "value"=>"no"},
   {"action"=>"fail", "message"=>"This rule should not have run"}],
 "conditions"=>[{"field"=>"memory_mb", "op"=>"lt", "value"=>42}, {"field"=>"local_gb", "op"=>"eq", "value"=>0}],
 "description"=>"Failing Rule",
 "links"=>[{"href"=>"/v1/rules/0d6e6687-3f69-4c14-8cab-ea6ada78036f", "rel"=>"self"}],
 "uuid"=>"0d6e6687-3f69-4c14-8cab-ea6ada78036f"}
```

### Delete a specific rules set

```ruby
inspector.delete_rules'0d6e6687-3f69-4c14-8cab-ea6ada78036f')
inspector.list_rules.body
=> {"rules"=>
  [{"description"=>"Successful Rule",
    "links"=>[{"href"=>"/v1/rules/4bf1bf40-d30f-4f31-a970-f0290d7e751b", "rel"=>"self"}],
    "uuid"=>"4bf1bf40-d30f-4f31-a970-f0290d7e751b"}]}
```

### Destroys all rules

```ruby
inspector.delete_rules_all
inspector.list_rules.body
=> {"rules"=>[]}
```
