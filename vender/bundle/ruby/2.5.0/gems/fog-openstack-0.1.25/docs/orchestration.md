# OpenStack Orchestration
The mission of the OpenStack Orchestration program is to create a human- and machine-accessible service for managing the entire lifecycle of infrastructure and applications within OpenStack clouds.

## Heat
Heat is the main project in the OpenStack Orchestration program. It implements an orchestration engine to launch multiple composite cloud applications based on templates in the form of text files that can be treated like code. A native Heat template format is evolving, but Heat also endeavours to provide compatibility with the AWS CloudFormation template format, so that many existing CloudFormation templates can be launched on OpenStack. Heat provides both an OpenStack-native ReST API and a CloudFormation-compatible Query API.

*Why ‘Heat’? It makes the clouds rise!*

**How it works**

* A Heat template describes the infrastructure for a cloud application in a text file that is readable and writable by humans, and can be checked into version control, diffed, &c.
* Infrastructure resources that can be described include: servers, floating ips, volumes, security groups, users, etc.
* Heat also provides an autoscaling service that integrates with Ceilometer, so you can include a scaling group as a resource in a template.
* Templates can also specify the relationships between resources (e.g. this volume is connected to this server). This enables Heat to call out to the OpenStack APIs to create all of your infrastructure in the correct order to completely launch your application.
* Heat manages the whole lifecycle of the application - when you need to change your infrastructure, simply modify the template and use it to update your existing stack. Heat knows how to make the necessary changes. It will delete all of the resources when you are finished with the application, too.
* Heat primarily manages infrastructure, but the templates integrate well with software configuration management tools such as Puppet and Chef. The Heat team is working on providing even better integration between infrastructure and software.

_Source: [OpenStack Wiki](https://wiki.openstack.org/wiki/Heat)_

# OpenStack Orchestration (Heat) Client

[Full OpenStack Orchestration/Heat API Docs](http://developer.openstack.org/api-ref-orchestration-v1.html)

## Orchestration Service
Get a handle on the Orchestration service:

```ruby
service = Fog::Orchestration::OpenStack.new({
  :openstack_auth_url  => 'http://KEYSTONE_HOST:KEYSTONE_PORT/v2.0/tokens', # OpenStack Keystone endpoint
  :openstack_username  => OPEN_STACK_USER,                                  # Your OpenStack Username
  :openstack_tenant    => OPEN_STACK_TENANT,                                # Your tenant id
  :openstack_api_key   => OPEN_STACK_PASSWORD,                              # Your OpenStack Password
  :connection_options  => {}                                                # Optional
})
```
We will use this `service` to interact with the Orchestration resources, `stack`, `event`,  `resource`, and `template`

Read more about the [Optional Connection Parameters](common/connection_params.md)

## Stacks

Get a list of stacks you own:

```ruby
service.stacks
```
This returns a list of stacks with minimum attributes, leaving other attributes empty
```ruby
=> <Fog::Orchestration::OpenStack::Stacks
    [
      <Fog::Orchestration::OpenStack::Stack
        id="0b8e4060-419b-416b-a927-097d4afbf26d",
        capabilities=nil,
        description="Simple template to deploy a single compute instance",
        disable_rollback=nil,
        links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/stack4/0b8e4060-419b-416b-a927-097d4afbf26d", "rel"=>"self"}],
        notification_topics=nil,
        outputs=nil,
        parameters=nil,
        stack_name="stack4",
        stack_status="UPDATE_COMPLETE",
        stack_status_reason="Stack successfully updated",
        template_description=nil,
        timeout_mins=nil,
        creation_time="2014-08-27T21:25:56Z",
        updated_time="2015-01-30T20:10:43Z"
      >,
      ...
```

Create a new `stack` with a [Heat Template (HOT)](http://docs.openstack.org/developer/heat/template_guide/hot_guide.html) or an AWS CloudFormation Template (CFN):

```ruby
raw_template = File.read(TEMPLATE_FILE)
service.stacks.new.save({
  :stack_name => "a_name_for_stack",
  :template   => raw_template,
  :parameters => {"flavor" => "m1.small", "image" => "cirror"}
})
```
This returns a JSON blob filled with information about our new stack:

```ruby
 {"id"=>"53b35fbe-34f7-4837-b0f8-8863b7263b7d",
 "links"=>[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/a_name_for_stack/53b35fbe-34f7-4837-b0f8-8863b7263b7d",
 "rel"=>"self"}]}
 ```

We can get a reference to the stack using its `stack_name` and `id`:

```ruby
stack = service.stacks.get("stack4", "0b8e4060-419b-416b-a927-097d4afbf26d")
```
This returns a stack with all attributes filled
```ruby
=>   <Fog::Orchestration::OpenStack::Stack
    id="0b8e4060-419b-416b-a927-097d4afbf26d",
    capabilities=[],
    description="Simple template to deploy a single compute instance",
    disable_rollback=true,
    links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/stack4/0b8e4060-419b-416b-a927-097d4afbf26d", "rel"=>"self"}],
    notification_topics=[],
    outputs=[],
    parameters={"AWS::StackId"=>"arn:openstack:heat::5d139d95546240748508b2a518aa5bef:stacks/stack4/0b8e4060-419b-416b-a927-097d4afbf26d", "AWS::Region"=>"ap-southeast-1", "AWS::StackName"=>"stack4"},
    stack_name="stack4",
    stack_status="UPDATE_COMPLETE",
    stack_status_reason="Stack successfully updated",
    template_description="Simple template to deploy a single compute instance",
    timeout_mins=60,
    creation_time="2014-08-27T21:25:56Z",
    updated_time="2015-01-30T20:10:43Z"
  >
```
It can be also obtained through the details method of a simple stack object
```ruby
stack.details
```

To update a stack while manipulating a Stack object from the Stack Collection:

```ruby
heat_template = { "template": { "description": "Updated description" } }
stack.save(heat_template)
```

`save` uses the `update_stack` request method, although it expects a Stack object as well:

```ruby
heat_template = { "template": { "description": "Updated description" } }
service.update_stack(stack, heat_template)
```

Alternatively a request only approach can be used, providing a stack id and name:

```ruby
id = "49b83314-d341-468a-aef4-44bbccce251e"
name = "stack_name"
heat_template = { "template": { "description": "Other update description" } }
service.update_stack(id, name, heat_template)
```

A stack knows about related `events`:

```ruby
stack.events
=>   <Fog::Orchestration::OpenStack::Events
    [
      <Fog::Orchestration::OpenStack::Event
        id="251",
        resource_name="my_instance",
        event_time="2015-01-21T20:08:51Z",
        links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/a_name_for_stack/53b35fbe-34f7-4837-b0f8-8863b7263b7d/resources/my_instance/events/251", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/a_name_for_stack/53b35fbe-34f7-4837-b0f8-8863b7263b7d/resources/my_instance", "rel"=>"resource"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/a_name_for_stack/53b35fbe-34f7-4837-b0f8-8863b7263b7d", "rel"=>"stack"}],
        logical_resource_id="my_instance",
        resource_status="CREATE_IN_PROGRESS",
        resource_status_reason="state changed",
        physical_resource_id=nil
      >,
```
A stack knows about related `resources`:

```ruby
stack.resources
=>   <Fog::Orchestration::OpenStack::Resources
    [
      <Fog::Orchestration::OpenStack::Resource
        id=nil,
        resource_name="my_instance",
        description=nil,
        links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"stack"}],
        logical_resource_id="my_instance",
        resource_status="CREATE_COMPLETE",
        updated_time="2014-09-12T20:44:06Z",
        required_by=[],
        resource_status_reason="state changed",
        resource_type="OS::Nova::Server"
      >
    ]
  >
```

You can get a stack's `template`

```ruby
stack.template
=>   <Fog::Orchestration::OpenStack::Template
    format="HOT",
    description="Simple template to deploy a single compute instance",
    template_version="2013-05-23",
    parameters=nil,
    resources=...
```

You can just delete a stack. This deletes associated `resources` :

```ruby
stack.delete
=> #<Excon::Response:0x007fe1066b2af8 @data={:body=>"", :headers=>{"Content-Type"=>"text/html; charset=UTF-8", "Content-Length"=>"0", "Date"=>"Wed, 21 Jan 2015 20:38:00 GMT"}, :status=>204, :reason_phrase=>"No Content", :remote_ip=>"10.8.96.4", :local_port=>59628, :local_address=>"10.17.68.186"}, @body="", @headers={"Content-Type"=>"text/html; charset=UTF-8", "Content-Length"=>"0", "Date"=>"Wed, 21 Jan 2015 20:38:00 GMT"}, @status=204, @remote_ip="10.8.96.4", @local_port=59628, @local_address="10.17.68.186">
```

Reload any object by calling `reload` on it:

```ruby
stacks.reload
=>   <Fog::Orchestration::OpenStack::Stacks
    [...]
  >
```

## Events

You can list `Events` of a `stack`:

```ruby
stack.events
=>   <Fog::Orchestration::OpenStack::Events
    [
      <Fog::Orchestration::OpenStack::Event
        id="15",
        resource_name="my_instance",
        event_time="2014-09-12T20:43:58Z",
        links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance/events/15", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance", "rel"=>"resource"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"stack"}],
        logical_resource_id="my_instance",
        resource_status="CREATE_IN_PROGRESS",
        resource_status_reason="state changed",
        physical_resource_id=nil
      >,
```

`Event` can be got through corresponding `resource`

```ruby
event = service.events.get(stack, resource, event_id)
=>   <Fog::Orchestration::OpenStack::Event
    id="15",
    resource_name="my_instance",
    event_time="2014-09-12T20:43:58Z",
    links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance/events/15", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance", "rel"=>"resource"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"stack"}],
    logical_resource_id="my_instance",
    resource_status="CREATE_IN_PROGRESS",
    resource_status_reason="state changed",
    physical_resource_id=nil
  >
```

An `event` knows about its associated `stack`:

```ruby
event.stack
=>   <Fog::Orchestration::OpenStack::Stack
    id="0c9ee370-ef64-4a80-a6cc-65d2277caeb9",
    description="Simple template to deploy a single compute instance",
    links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"self"}],
    stack_status_reason="Stack create completed successfully",
    stack_name="progenerated",
    creation_time="2014-09-12T20:43:58Z",
    updated_time="2014-09-12T20:44:06Z"
  >
```
An  `event` has an associated `resource`:

```ruby
resource = event.resource
=>   <Fog::Orchestration::OpenStack::Resource
    id=nil,
    resource_name="my_instance",
    description="",
    links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"stack"}],
    logical_resource_id="my_instance",
    resource_status="CREATE_COMPLETE",
    updated_time="2014-09-12T20:44:06Z",
    required_by=[],
    resource_status_reason="state changed",
    resource_type="OS::Nova::Server"
  >
```

## Resource

`resources` might be nested:

```ruby
service.resources.all(stack, {:nested_depth => 1})
=>   <Fog::Orchestration::OpenStack::Resources
    [
      <Fog::Orchestration::OpenStack::Resource
        id=nil,
        resource_name="my_instance",
        description=nil,
        links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9/resources/my_instance", "rel"=>"self"}, {"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"stack"}],
        logical_resource_id="my_instance",
        resource_status="CREATE_COMPLETE",
        updated_time="2014-09-12T20:44:06Z",
        required_by=[],
        resource_status_reason="state changed",
        resource_type="OS::Nova::Server"
      >
    ]
  >
```

A `resource` knows about its associated `stack`:

```ruby
resource.stack
=>   <Fog::Orchestration::OpenStack::Stack
    id="0c9ee370-ef64-4a80-a6cc-65d2277caeb9",
    description="Simple template to deploy a single compute instance",
    links=[{"href"=>"http://10.8.96.4:8004/v1/5d139d95546240748508b2a518aa5bef/stacks/progenerated/0c9ee370-ef64-4a80-a6cc-65d2277caeb9", "rel"=>"self"}],
    stack_status_reason="Stack create completed successfully",
    stack_name="progenerated",
    creation_time="2014-09-12T20:43:58Z",
    updated_time="2014-09-12T20:44:06Z"
  >
```

Resource metadata is visible:

```ruby
irb: resource.metadata
=> {}
```

A `resource's` template is visible (if one exists)

```ruby
irb: resource.template
=> nil
```

## Validation
You can validate a template (either HOT or CFN) before using it:

```ruby
service.templates.validate(:template => content)
=>   <Fog::Orchestration::OpenStack::Template
    format=nil,
    description="Simple template to deploy a single compute instance",
    template_version=nil,
    parameters={},
    resources=nil,
    content=nil
  >
```

## Cancel Update
When the stack is updating, you can cancel the update:

```ruby
# stack.stack_status == 'UPDATE_IN_PROGRESS'
stack.cancel_update
=> nil
```

Then you can see the status changed to ROLLBACK_IN_PROGRESS:

```ruby
stack = service.stacks.get(stack.stack_name, stack.id)
stack.stack_status
=> "ROLLBACK_IN_PROGRESS"
```
