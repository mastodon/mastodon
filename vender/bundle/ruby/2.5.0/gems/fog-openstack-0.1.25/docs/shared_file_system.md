# Shared File System (Manila)

This document explains how to get started using OpenStack Shared File System (Manila) with Fog. It assumes you have read the [Getting Started with Fog and OpenStack](getting_started.md) document.

## Starting irb console

Start by executing the following command:
```
irb
```

or if you use bundler for managing your gems:
```
bundle exec irb
```

Once `irb` has launched you need to require the Fog library by executing:
```
require 'fog/openstack'
```
## Create Service

Next, create a connection to the Shared File System Service:
```
service = Fog::SharedFileSystem::OpenStack.new(
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

The request abstraction maps directly to the [OpenStack Shared File System API](http://developer.openstack.org/api-ref/shared-file-systems). It provides the most efficient interface to the OpenStack Shared File System service.

To see a list of requests supported by the service:
```
service.requests
```

#### Example Request

To request a list of networks:
```
response = service.list_shares
```

To learn more about Shared File System request methods refer to [rdoc](http://www.rubydoc.info/gems/fog-openstack/Fog/SharedFileSystem/OpenStack/Real).

### Model Layer

Fog models behave in a manner similar to `ActiveModel`. Models will generally respond to `create`, `save`,  `persisted?`, `destroy`, `reload` and `attributes` methods. Additionally, fog will automatically create attribute accessors.

To see a list of collections supported by the service:
```
service.collections
```

#### Example Request

To request a collection of share networks:
```
networks = service.networks
```

## Examples

Example code using Shared File System can be found [here](https://github.com/fog/fog-openstack/tree/master/examples/share).

## Additional Resources

* [OpenStack Shared File System API](http://developer.openstack.org/api-ref/shared-file-systems/)
* [more resources and feedback](common/resources.md)
