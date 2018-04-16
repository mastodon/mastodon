# Fog::Openstack

[![Gem Version](https://badge.fury.io/rb/fog-openstack.svg)](http://badge.fury.io/rb/fog-openstack) [![Build Status](https://travis-ci.org/fog/fog-openstack.svg?branch=master)](https://travis-ci.org/fog/fog-openstack) [![Dependency Status](https://gemnasium.com/fog/fog-openstack.svg)](https://gemnasium.com/fog/fog-openstack) [![Coverage Status](https://coveralls.io/repos/github/fog/fog-openstack/badge.svg?branch=master)](https://coveralls.io/github/fog/fog-openstack?branch=master) [![Code Climate](https://codeclimate.com/github/fog/fog-openstack.svg)](https://codeclimate.com/github/fog/fog-openstack) [![Join the chat at https://gitter.im/fog/fog-openstack](https://badges.gitter.im/fog/fog-openstack.svg)](https://gitter.im/fog/fog-openstack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the plugin Gem to talk to [OpenStack](http://openstack.org) clouds via fog.

The main maintainers for the OpenStack sections are @dhague, @Ladas, @seanhandley, @mdarby and @jjasghar. Please send CC them on pull requests.

## Supported OpenStack APIs

See the list of [supported OpenStack projects](supported.md).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fog-openstack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fog-openstack

## Usage

### Initial Setup

Require the gem:

```ruby
require "fog/openstack"
```

Checklist:

* Before you can do anything with an OpenStack cloud, you need to authenticate yourself with the identity service, "Keystone".
* All following examples assume that `@connection_params` is a hash of valid connection information for an OpenStack cloud.
* The `:openstack_username` and `:openstack_api_key` keys must map to a valid user/password combination in Keystone.
* If you don't know what domain your user belongs to, chances are it's the `default` domain. By default, all users are a member of the `default` domain unless otherwise specified.

Connection parameters:

```ruby
@connection_params = {
  openstack_auth_url:     "http://devstack.test:5000/v3/auth/tokens",
  openstack_username:     "admin",
  openstack_api_key:      "password",
  openstack_project_name: "admin",
  openstack_domain_id:    "default"
}
```

If you're using Keystone V2, you don't need to supply domain details but ensure the `openstack_auth_url` parameter references the correct endpoint.

```ruby
@connection_params = {
  openstack_auth_url:     "http://devstack.test:5000/v2.0/tokens",
  openstack_username:     "admin",
  openstack_api_key:      "password",
  openstack_project_name: "admin"
}
```

If you're not sure whether your OpenStack cloud uses Keystone V2 or V3 then you can find out by logging into the dashboard (Horizon) and navigating to "Access & Security" under the "Project" section. Select "API Access" and find the line for the Identity Service. If the endpoint has "v3" in it, you're on Keystone V3, if it has "v2" then (surprise) you're on Keystone V2.

If you need a version of OpenStack to test against, get youself a copy of [DevStack](http://docs.openstack.org/developer/devstack/).

### Networking Gotcha

Note that tenants (aka projects) in OpenStack usually require that you create a default gateway router in order to allow external access to your instances.

The exception is if you're using Nova (and not Neutron) for your instance networking. If you're using Neutron, you'll want to [set up your default gateway](https://github.com/fog/fog-openstack/blob/usage_doc/README.md#networking-neutron) before you try to give instances public addresses (aka floating IPs).

### Compute (Nova)

Initialise a connection to the compute service:

```ruby
compute = Fog::Compute::OpenStack.new(@connection_params)
```

Get a list of available images for use with booting new instances:

```ruby
p compute.images
# =>   <Fog::Compute::OpenStack::Images
#     filters={},
#     server=nil
#     [
#                   <Fog::Compute::OpenStack::Image
#         id="57a67f8a-7bae-4578-b684-b9b4dcd48d7f",
#         ...
#       >    
#     ]
#   >
```

List available flavors so we can decide how powerful to make this instance:

```ruby
p compute.flavors
# =>   <Fog::Compute::OpenStack::Flavors
#     [
#                   <Fog::Compute::OpenStack::Flavor
#         id="1",
#         name="m1.tiny",
#         ram=512,
#         disk=1,
#         vcpus=1,
#         ...
#       >,
#                   <Fog::Compute::OpenStack::Flavor
#         id="2",
#         name="m1.small",
#         ram=2048,
#         disk=20,
#         vcpus=1,
#         ...
#       >,
#       ...

```

Now we know the `id` numbers of a valid image and a valid flavor, we can instantiate an instance:

```ruby
flavor   = compute.flavors[0]
image    = compute.images[0]
instance = compute.servers.create name: 'test',
                                  image_ref: image.id,
                                  flavor_ref: flavor.id

# Optionally, wait for the instance to provision before continuing
instance.wait_for { ready? }
# => {:duration=>17.359134}

p instance
# =>   <Fog::Compute::OpenStack::Server
#     id="63633125-26b5-4fe1-a909-0f44d1ab3337",
#     instance_name=nil,
#     addresses={"public"=>[{"OS-EXT-IPS-MAC:mac_addr"=>"fa:16:3e:f4:75:ab", "version"=>4, "addr"=>"1.2.3.4", "OS-EXT-IPS:type"=>"fixed"}]},
#     flavor={"id"=>"2"},
#     host_id="f5ea01262720d02e886508bc4fa994782c516557d232c72aeb79638e",
#     image={"id"=>"57a67f8a-7bae-4578-b684-b9b4dcd48d7f"},
#     name="test",
#     personality=nil,
#     progress=0,
#     accessIPv4="",
#     accessIPv6="",
#     availability_zone="nova",
#     user_data_encoded=nil,
#     state="ACTIVE",
#     created=2016-03-07 08:07:36 UTC,
#     updated=2016-03-07 08:07:52 UTC,
#     tenant_id="06a9a90c60074cdeae5f7fdd0048d9ac"
#     ...
#   >
```

And destroy it when we're done:

```ruby
instance.destroy
# => true
```

You'll probably need your instances to be accessible via SSH. [Learn more about SSH keypairs](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

Allow TCP traffic through port 22:

```ruby
security_group = compute.security_groups.create name:  "Test SSH",
                                                description: "Allow access to port 22"
# =>   <Fog::Compute::OpenStack::SecurityGroup
#     id="e5d53d00-b3f9-471a-b90f-985694b966ed",
#     name="Test SSH",
#     description="Allow access to port 22",
#     security_group_rules=    <Fog::Compute::OpenStack::SecurityGroupRules
#       [

#       ]
#     >,
#     tenant_id="06a9a90c60074cdeae5f7fdd0048d9ac"
#   >

compute.security_group_rules.create parent_group_id: security_group.id,
                                    ip_protocol:     "tcp",
                                    from_port:       22,
                                    to_port:         22

key_pair = compute.key_pairs.create name:       "My Public Key",
                                    public_key: "/full/path/to/ssh.pub"
# =>   <Fog::Compute::OpenStack::KeyPair
#     name="My Public Key",
#     ...
#     user_id="20746f49211e4037a91269df6a3fbf7b",
#     id=nil
#   >
```

Now create a new server using the security group and keypair we created:

```ruby
instance = compute.servers.create name:            "Test 2",
                                  image_ref:       image.id,
                                  flavor_ref:      flavor.id,
                                  key_name:        key_pair.name,
                                  security_groups: security_group
# =>   <Fog::Compute::OpenStack::Server
#     id="e18ebdfb-e5f5-4a45-929f-4cc9926dc2c7",
#     name="Test 2",
#     state="ACTIVE",
#     tenant_id="06a9a90c60074cdeae5f7fdd0048d9ac",
#     key_name="My Public Key",
#   >
# (some data omitted for brevity)
```

Finally, assign a floating IP address to make this instance sit under a world-visible public IP address:

```ruby
pool_name = compute.addresses.get_address_pools[0]['name']
floating_ip_address = compute.addresses.create pool: pool_name
instance.associate_address floating_ip_address.ip

p floating_ip_address
# =>   <Fog::Compute::OpenStack::Address
#     id="54064324-ce7d-448d-9753-94497b29dc91",
#     ip="1.2.3.4",
#     pool="external",
#     fixed_ip="192.168.0.96",
#     instance_id="e18ebdfb-e5f5-4a45-929f-4cc9926dc2c7"
#   >
```

Now you can SSH into the instance:

```
$ ssh cirros@1.2.3.4
The authenticity of host '1.2.3.4 (1.2.3.4)' can't be established.
RSA key fingerprint is SHA256:cB0L/owUtcHsMhFhsuSZXxK4oRg/uqP/6IriUomQnQQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '1.2.3.4' (RSA) to the list of known hosts.
$ pwd
/home/cirros
```

### Volume (Cinder)

Create and attach a volume to a running instance:

```ruby
compute = Fog::Compute::OpenStack.new(@connection_params)

volume = compute.volumes.create name:        "Test",
                                description: "Testing",
                                size:        1
# =>   <Fog::Compute::OpenStack::Volume
#     id="4a212986-c6b6-4a93-8319-c6a98e347750",
#     name="Test",
#     description="Testing",
#     size=1,
#     availability_zone="Production",
#     created_at="2016-03-07T13:40:43.914063",
#     attachments=[{}]
#   >

flavor   = compute.flavors[3]
image    = compute.images[0]
instance = compute.servers.create name:       "test",
                                  image_ref:  image.id,
                                  flavor_ref: flavor.id
instance.wait_for { ready? }

volume.reload

instance.attach_volume(volume.id, "/dev/vdb")
```

Detach volume and create a snapshot:

```ruby
instance.detach_volume(volume.id)
volume.reload

compute.snapshots.create volume_id:   volume.id,
                         name:        "test",
                         description: "test"
# =>   <Fog::Compute::OpenStack::Snapshot
#     id="7a8c9192-25ee-4364-be91-070b7a6d9855",
#     name="test",
#     description="test",
#     volume_id="4a212986-c6b6-4a93-8319-c6a98e347750",
#     status="creating",
#     size=1,
#     created_at="2016-03-07T13:47:11.543814"
#   >
```

Destroy a volume:
```ruby
volume.destroy
# => true
```

### Image (Glance)

Download Glance image:

```ruby

image = Fog::Image::OpenStack.new(@connection_params)

image_out = File.open("/tmp/cirros-image-download", 'wb')

streamer = lambda do |chunk, _, _|
  image_out.write chunk
end

image.download_image(image.images.first.id, response_block: streamer)

```

Create Glance image from file or URL:

```ruby

cirros_location = "http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img"
image_out = File.open("/tmp/cirros-image-#{SecureRandom.hex}", 'wb')

streamer = lambda do |chunk, _, _|
  image_out.write chunk
end

Excon.get cirros_location, response_block: streamer
image_out.close

image_handle = image.images.create name:             "cirros",
                                   disk_format:      "qcow2",
                                   container_format: "bare"

# => <Fog::Image::OpenStack::V2::Image
#      id="67c4d02c-5601-4619-bd14-d2f7f96a046c",
#      name="cirros",
#      visibility="private",
#      tags=[],
#      self="/v2/images/67c4d02c-5601-4619-bd14-d2f7f96a046c",
#      size=nil,
#      disk_format="qcow2",
#      container_format="bare",
#      id="67c4d02c-5601-4619-bd14-d2f7f96a046c",
#      checksum=nil,
#      self="/v2/images/67c4d02c-5601-4619-bd14-d2f7f96a046c",
#      file="/v2/images/67c4d02c-5601-4619-bd14-d2f7f96a046c/file",
#      min_disk=0,
#      created_at="2016-10-31T03:38:28Z",
#      updated_at="2016-10-31T03:38:28Z",
#      protected=false,
#      status="queued",
#      min_ram=0,
#      owner="6b9ec8080b8443c5afe2267a39b9bf74",
#      properties=nil,
#      metadata=nil,
#      location=nil,
#      network_allocated=nil,
#      base_image_ref=nil,
#      image_type=nil,
#      instance_uuid=nil,
#      user_id=nil
#    >


image_handle.upload_data File.binread(image_out.path)

```

Destroy image:

```ruby
cirros = image.images.get("4beedb46-e32f-4ef3-a87b-7f1234294dc1")
cirros.destroy
```

### Identity (Keystone)

List domains (Keystone V3 only):

```ruby
identity = Fog::Identity::OpenStack.new(@connection_params)

identity.domains
# =>   <Fog::Identity::OpenStack::V3::Domains
#     [
#                   <Fog::Identity::OpenStack::V3::Domain
#         id="default",
#         description="",
#         enabled=true,
#         name="Default",
#       >    
#     ]
#   >
```

List projects (aka tenants):

```ruby
identity.projects
# =>   <Fog::Identity::OpenStack::V3::Projects
#     [
#                   <Fog::Identity::OpenStack::V3::Project
#         id="008e5537d3424295a03560abc923693c",
#         domain_id="default",
#         description="Project 1",
#         enabled=true,
#         name="project_1",
#       >,
#        ...
#        ]

# On Keystone V2
identity.tenants
# =>   <Fog::Identity::OpenStack::V2::Tenants
#     [ ... ]
```

List users:

```ruby
identity.users
# =>   <Fog::Identity::OpenStack::V3::Users
#     [ ... ]
```

Create/destroy new user:

```ruby
project_id = identity.projects[0].id

user = identity.users.create name: "test",
                             project_id: project_id,
                             email: "test@test.com",
                             password: "test"
# =>   <Fog::Identity::OpenStack::V3::User
#     id="474a59153ebd4e709938e5e9b614dc57",
#     default_project_id=nil,
#     description=nil,
#     domain_id="default",
#     email="test@test.com",
#     enabled=true,
#     name="test",
#     password="test"
#   >

user.destroy
# => true
```

Create/destroy new tenant:

```ruby

project = identity.projects.create name: "test",
                                   description: "test"
# =>   <Fog::Identity::OpenStack::V3::Project
#     id="423559128a7249f2973cdb7d5d581c4d",
#     domain_id="default",
#     description="test",
#     enabled=true,
#     name="test",
#     parent_id=nil,
#     subtree=nil,
#     parents=nil
#   >

project.destroy
# => true
```

Grant user role on tenant and revoke it:

```ruby
role = identity.roles.select{|role| role.name == "_member_"}[0]
# =>   <Fog::Identity::OpenStack::V3::Role
#     id="9fe2ff9ee4384b1894a90878d3e92bab",
#     name="_member_",
#   >

project.grant_role_to_user(role.id, user.id)

project.revoke_role_from_user(role.id, user.id)
```

### Networking (Neutron)

Set up a project's public gateway (needed for external access):

```ruby

identity  = Fog::Identity::OpenStack.new(@connection_params)

tenants = identity.projects.select do |project|
  project.name == @connection_params[:openstack_project_name]
end

tenant_id = tenants[0].id

neutron = Fog::Network::OpenStack.new(@connection_params)

network = neutron.networks.create name:      "default",
                                  tenant_id: tenant_id

subnet  = network.subnets.create  name:            "default",
                                  cidr:            "192.168.0.0/24",
                                  network_id:      network.id,
                                  ip_version:      4,
                                  dns_nameservers: ["8.8.8.8", "8.8.4.4"],
                                  tenant_id:       tenant_id

external_network = neutron.networks.select(&:router_external)[0]

router = neutron.routers.create   name:                  'default',
                                  tenant_id:             tenant_id,
                                  external_gateway_info: external_network.id

neutron.add_router_interface router.id, subnet.id

```

### Further Reading

* See [the documentation directory](https://github.com/fog/fog-openstack/tree/master/lib/fog/openstack/docs) for more examples.
* Read the [OpenStack API documentation](http://developer.openstack.org/api-ref.html).
* Also, remember that reading the code itself is the best way to educate yourself on how best to interact with this gem.

## Development

```
$ git clone https://github.com/fog/fog-openstack.git # Clone repository
$ cd fog-openstack; bin/setup   # Install dependencies from project directory
$ bundle exec rake test   # Run tests
$ bundle exec rake spec   # Run tests
$ bin/console   # Run interactive prompt that allows you to experiment (optional)
$ bundle exec rake install   # Install gem to your local machine (optional)
```

You can also use a docker image for development and running tests. Once you have
cloned the repository, it can be run with:
```
$ docker-compose up test
$ docker-compose up ruby # Start a container with the ruby environment
```

In order to release a new version, perform the following steps:

1. Update version number in `version.rb`.
2. Run `bundle exec rake release`, which will create a git tag for the version.
3. Push git commits and tags.
4. Push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fog/fog-openstack. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
