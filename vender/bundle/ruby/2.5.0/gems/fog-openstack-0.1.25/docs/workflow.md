# OpenStack Workflow (Mistral)

This document explains how to get started using OpenStack Workflow (Mistral) with Fog. It assumes you have read the [Getting Started with Fog and the OpenStack](getting_started.md) document.

Fog uses the [OpenStack Mistral API](http://docs.openstack.org/developer/mistral/developer/webapi/v2.html).

## Workflow Service

Get a handle for the Workflow service:

```ruby
service = Fog::Workflow::OpenStack.new({
  :openstack_auth_url  => 'http://KEYSTONE_HOST:KEYSTONE_PORT/v2.0/tokens', # OpenStack Keystone endpoint
  :openstack_username  => OPEN_STACK_USER,                                  # Your OpenStack Username
  :openstack_tenant    => OPEN_STACK_TENANT,                                # Your tenant id
  :openstack_api_key   => OPEN_STACK_PASSWORD,                              # Your OpenStack Password
  :connection_options  => {}                                                # Optional
})
```

Read more about the [Optional Connection Parameters](common/connection_params.md)

## Executions

A Workflow is a composition of one or more actions.

To execute a workflow, we create an execution:

```ruby
workflow = "tripleo.plan_management.v1.create_default_deployment_plan"
input = { :container => 'default' }
response = service.create_execution(workflow, input)
```

Execution status and result can be checked by:

```ruby
workflow_execution_id = response.body["id"]
response = mistral.get_execution(workflow_execution_id)
state = response.body["state"]
```

To execute an individual action, we create an action execution:

```ruby
input = { :container => 'default' }
service.create_action_execution("tripleo.get_capabilities", input)
```

For actions, the result is returned when create_action_execution completes.

## Workflows

### Create a workflow

```ruby
workflow_def = {
  :version => "2.0",
  :myworkflow => {
    :type        => "direct",
    :description => "description1",
    :tasks => {
      :create_vm => {
        :description => "create vm"
      }
    }
  }
}
response = service.create_workflow(workflow_def)
workflow_id = response.body["workflows"][0]["id"]
```

### Validate a workflow before creating it

```ruby
service.validate_workflow(workflow_def)
```

### Update a workflow

```ruby
workflow_def_new = {
  :version => "2.0",
  :myworkflow => {
    :type        => "direct",
    :description => "description2",
    :tasks => {
      :create_vm => {
        :description => "create vm"
      }
    }
  }
}
service.update_workflow(workflow_def_new)
```

### List workflow

```ruby
service.list_workflows
```

### Delete workflow

```ruby
service.delete_workflow(workflow_id)
```

## Other Mistral resources

In addition to workflows, the following Mistral resources are also supported:

* Workbooks
* Actions
* Executions
* Tasks
* Action Executions
* Cron Triggers
* Environments
* Validations

For examples on how to interact with these resources, please refer to
https://github.com/fog/fog-openstack/tree/master/examples/workflow/workflow-examples.rb

## Additional Resources

* [Mistral Wiki](https://wiki.openstack.org/wiki/Mistral)
* [Mistral DSL v2](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html)
* [Mistral API v2](http://docs.openstack.org/developer/mistral/developer/webapi/v2.html)
* [Mistral python client](https://github.com/openstack/python-mistralclient) Can be useful to see how to interact with the API.
* [more resources and feedback](common/resources.md)
