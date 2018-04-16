# Planning

This document explains how to get started using OpenStack Tuskar with Fog.


## Starting irb console

Start by executing the following command:

```bash
irb
```

Once `irb` has launched you need to require the Fog library.

If using Ruby 1.8.x execute:

```ruby
require 'rubygems'
require 'fog/openstack'
```

If using Ruby 1.9.x execute:

```ruby
require 'fog/openstack'
```

## Create Service

Next, create a connection to Tuskar:

```ruby
service = Fog::Openstack.new({
  :service             => :planning,     # OpenStack Fog service
  :openstack_username  => USERNAME,      # Your OpenStack Username
  :openstack_api_key   => PASSWORD,      # Your OpenStack Password
  :openstack_auth_url  => 'http://YOUR_OPENSTACK_ENDPOINT:PORT/v2.0/tokens'
  :connection_options  => {}             # Optional
})
```

Read more about the [Optional Connection Parameters](common/connection_params.md)

## Fog Abstractions

Fog provides both a **model** and **request** abstraction. The request abstraction provides the most efficient interface and the model abstraction wraps the request abstraction to provide a convenient `ActiveModel` like interface.

### Request Layer

The `Fog::Openstack[:planning]` object supports a number of methods that wrap individual HTTP requests to the Tuskar API.

To see a list of requests supported by the planning service:

```ruby
service.requests
```

This returns:

```ruby
[
  :list_roles,
  :list_plans,
  :get_plan_templates,
  :get_plan,
  :patch_plan,
  :create_plan,
  :delete_plan,
  :add_role_to_plan,
  :remove_role_from_plan
]

```


#### Example Request

To request a list of plans:

```ruby
response = service.list_plans
```

This returns in the following `Excon::Response`:

```ruby
#<Excon::Response:0x007f141e045ab8
@data=
  {
    :body=>
    [
      {
	"created_at"=>"2014-09-26T20:23:14.222815",
	"description"=>"Development testing cloud",
	"name"=>"dev-cloud",
	"parameters"=>
	  [
	  {
	    "default"=>"guest",
	    "description"=>"The password for RabbitMQ",
	    "hidden"=>true,
	    "label"=>nil,
	    "name"=>"compute-1 => =>RabbitPassword",
	    "value"=>"secret-password"
	  },
	  {
	    "default"=>"default",
	    "description"=>"description",
	    "hidden"=>true,
	    "label"=>nil,
	    "name"=>"name",
	    "value"=>"value"
	  }
	  ],
	"roles"=>
	  [
	  {
	    "description"=>"OpenStack hypervisor node. Can be wrapped in a ResourceGroup for scaling.\n",
	    "name"=>"compute",
	    "uuid"=>"b7b1583c-5c80-481f-a25b-708ed4a39734",
	    "version"=>1
	  }
	  ],
	"updated_at"=>nil,
	"uuid"=>"53268a27-afc8-4b21-839f-90227dd7a001"
      }
    ],
    :headers=>{},
    :status=>200
  },
  @body="",
  @headers={},
  @status=nil,
  @remote_ip=nil,
  @local_port=nil,
  @local_address=nil
>
```

To view the status of the response:

```ruby
response.status
```

**Note**: Fog is aware of the valid HTTP response statuses for each request type. If an unexpected HTTP response status occurs, Fog will raise an exception.

To view response headers:

```ruby
response.headers
```

This will return hash similar to:

```ruby
{
  "X-Account-Bytes-Used"=>"2563554",
  "Date"=>"Thu, 21 Feb 2013 21:57:02 GMT",
  "X-Account-Meta-Temp-Url-Key"=>"super_secret_key",
  "X-Timestamp"=>"1354552916.82056",
  "Content-Length"=>"0",
  "Content-Type"=>"application/json; charset=utf-8",
  "X-Trans-Id"=>"txe934924374a744c8a6c40dd8f29ab94a",
  "Accept-Ranges"=>"bytes",
  "X-Account-Container-Count"=>"7",
  "X-Account-Object-Count"=>"5"
}
```

[//]: # (TODO: Specify URL to rubydoc.info when OpenStack Planning service is part of release and pages are built)
To learn more about `Fog::Openstack[:planning]` request methods refer to [rdoc](http://rubydoc.info/gems/fog/Fog). To learn more about Excon refer to [Excon GitHub repo](https://github.com/geemus/excon).

### Model Layer

Fog models behave in a manner similar to `ActiveModel`. Models will generally respond to `create`, `save`,  `destroy`, `reload` and `attributes` methods. Additionally, fog will automatically create attribute accessors.

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
<td>destroy</td>
<td>
Destroys object.<br>
Note: this is a non-blocking call and object deletion might not be instantaneous.
</td>
<tr>
<td>reload</td>
<td>Updates object with latest state from service.</td>
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
</table>

The remainder of this document details the model abstraction.


## Additional Resources

* [Tuskar API](http://docs.openstack.org/developer/tuskar/)
* [more resources and feedback](common/resources.md)
