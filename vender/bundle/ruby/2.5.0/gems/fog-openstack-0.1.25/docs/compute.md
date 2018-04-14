#Compute (Nova)

This document explains how to get started using OpenStack Compute (Nova) with Fog. It assumes you have read the [Getting Started with Fog and the OpenStack](getting_started.md) document.

## Starting irb console

Start by executing the following command:

	irb

Once `irb` has launched you need to require the Fog library by executing:

	require 'fog/openstack'

## Create Service

Next, create a connection to the Compute Service:

	service = Fog::Compute::OpenStack.new({
		:openstack_auth_url  => 'http://KEYSTONE_HOST:KEYSTONE_PORT/v2.0/tokens', # OpenStack Keystone endpoint
		:openstack_username  => OPEN_STACK_USER,                                  # Your OpenStack Username
		:openstack_tenant    => OPEN_STACK_TENANT,                                # Your tenant id
		:openstack_api_key   => OPEN_STACK_PASSWORD,                              # Your OpenStack Password
		:connection_options  => {}                                                # Optional
	})

**Note** `openstack_username` and `openstack_tenant` default to `admin` if omitted.

Read more about the [Optional Connection Parameters](common/connection_params.md)


## Fog Abstractions

Fog provides both a **model** and **request** abstraction. The request abstraction provides the most efficient interface and the model abstraction wraps the request abstraction to provide a convenient `ActiveModel` like interface.

### Request Layer

The request abstraction maps directly to the [OpenStack Compute API](http://docs.openstack.org/api/openstack-compute/2/content/). It provides the most efficient interface to the OpenStack Compute service.

To see a list of requests supported by the service:

	service.requests

This returns:

	:list_servers, :list_servers_detail, :create_server, :get_server_details, :update_server, :delete_server, :server_actions, :server_action, :reboot_server, :rebuild_server, :resize_server, :confirm_resize_server, :revert_resize_server, :pause_server, :unpause_server, :suspend_server, :resume_server, :rescue_server, :change_server_password, :add_fixed_ip, :remove_fixed_ip, :server_diagnostics, :boot_from_snapshot, :reset_server_state, :get_console_output, :get_vnc_console, :live_migrate_server, :migrate_server, :list_images, :list_images_detail, :create_image, :get_image_details, :delete_image, :list_flavors, :list_flavors_detail, :get_flavor_details, :create_flavor, :delete_flavor, :add_flavor_access, :remove_flavor_access, :list_tenants_with_flavor_access, :list_metadata, :get_metadata, :set_metadata, :update_metadata, :delete_metadata, :delete_meta, :update_meta, :list_addresses, :list_address_pools, :list_all_addresses, :list_private_addresses, :list_public_addresses, :get_address, :allocate_address, :associate_address, :release_address, :disassociate_address, :list_security_groups, :get_security_group, :create_security_group, :create_security_group_rule, :delete_security_group, :delete_security_group_rule, :get_security_group_rule, :list_key_pairs, :create_key_pair, :delete_key_pair, :list_tenants, :set_tenant, :get_limits, :list_volumes, :create_volume, :get_volume_details, :delete_volume, :attach_volume, :detach_volume, :get_server_volumes, :create_snapshot, :list_snapshots, :get_snapshot_details, :delete_snapshot, :list_usages, :get_usage, :get_quota, :get_quota_defaults, :update_quota, :list_hosts, :get_host_details


#### Example Request

To request a list of flavors:

	response = service.list_flavors

This returns in the following `Excon::Response`:

	#<Excon::Response:0x007f88a12d0268 @data={:body=>{"flavors"=>[{"id"=>"1", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}], "name"=>"m1.tiny"}, {"id"=>"2", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"bookmark"}], "name"=>"m1.small"}, {"id"=>"3", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3", "rel"=>"bookmark"}], "name"=>"m1.medium"}, {"id"=>"4", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4", "rel"=>"bookmark"}], "name"=>"m1.large"}, {"id"=>"42", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42", "rel"=>"bookmark"}], "name"=>"m1.nano"}, {"id"=>"5", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5", "rel"=>"bookmark"}], "name"=>"m1.xlarge"}, {"id"=>"84", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84", "rel"=>"bookmark"}], "name"=>"m1.micro"}]}, :headers=>{"Content-Type"=>"application/json", "Content-Length"=>"1748", "X-Compute-Request-Id"=>"req-ae3bcf11-deab-493b-a2d8-1432dead3f7a", "Date"=>"Thu, 09 Jan 2014 17:01:15 GMT"}, :status=>200, :remote_ip=>"localhost"}, @body="{\"flavors\": [{\"id\": \"1\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1\", \"rel\": \"bookmark\"}], \"name\": \"m1.tiny\"}, {\"id\": \"2\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2\", \"rel\": \"bookmark\"}], \"name\": \"m1.small\"}, {\"id\": \"3\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3\", \"rel\": \"bookmark\"}], \"name\": \"m1.medium\"}, {\"id\": \"4\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4\", \"rel\": \"bookmark\"}], \"name\": \"m1.large\"}, {\"id\": \"42\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42\", \"rel\": \"bookmark\"}], \"name\": \"m1.nano\"}, {\"id\": \"5\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5\", \"rel\": \"bookmark\"}], \"name\": \"m1.xlarge\"}, {\"id\": \"84\", \"links\": [{\"href\": \"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84\", \"rel\": \"self\"}, {\"href\": \"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84\", \"rel\": \"bookmark\"}], \"name\": \"m1.micro\"}]}", @headers={"Content-Type"=>"application/json", "Content-Length"=>"1748", "X-Compute-Request-Id"=>"req-ae3bcf11-deab-493b-a2d8-1432dead3f7a", "Date"=>"Thu, 09 Jan 2014 17:01:15 GMT"}, @status=200, @remote_ip="localhost">

To view the status of the response:

	response.status

**Note**: Fog is aware of valid HTTP response statuses for each request type. If an unexpected HTTP response status occurs, Fog will raise an exception.

To view response body:

	response.body

This will return:

	{"flavors"=>[{"id"=>"1", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}], "name"=>"m1.tiny"}, {"id"=>"2", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"bookmark"}], "name"=>"m1.small"}, {"id"=>"3", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/3", "rel"=>"bookmark"}], "name"=>"m1.medium"}, {"id"=>"4", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/4", "rel"=>"bookmark"}], "name"=>"m1.large"}, {"id"=>"42", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/42", "rel"=>"bookmark"}], "name"=>"m1.nano"}, {"id"=>"5", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/5", "rel"=>"bookmark"}], "name"=>"m1.xlarge"}, {"id"=>"84", "links"=>[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/84", "rel"=>"bookmark"}], "name"=>"m1.micro"}]}


To learn more about Compute request methods refer to [rdoc](http://rubydoc.info/gems/fog/Fog/Compute/Openstack/Real). To learn more about Excon refer to [Excon GitHub repo](https://github.com/geemus/excon).

### Model Layer

Fog models behave in a manner similar to `ActiveModel`. Models will generally respond to `create`, `save`,  `persisted?`, `destroy`, `reload` and `attributes` methods. Additionally, fog will automatically create attribute accessors.

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
		<td>persisted?</td>
		<td>Returns true if the object has been persisted.</td>
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
		<td>ready?</td>
		<td>Returns true if object is in a ready state and able to perform actions. This method will raise an exception if object is in an error state.</td>
	</tr>
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
	<tr>
		<td>wait_for</td>
		<td>This method periodically reloads model and then yields to specified block until block returns true or a timeout occurs.</td>
	</tr>
</table>

The remainder of this document details the model abstraction.

## List Images

To retrieve a list of available images:

	service.images

This returns a collection of `Fog::Compute::OpenStack::Image` models:

	<Fog::Compute::OpenStack::Images
    filters={},
    server=nil
    [
      <Fog::Compute::OpenStack::Image
        id="821e2b73-5aed-4f9d-aaa7-2f4f297779f3",
        name="cirros-0.3.1-x86_64-uec",
        created_at="2013-07-11T19:59:19Z",
        updated_at="2013-07-11T19:59:20Z",
        progress=100,
        status="ACTIVE",
        minDisk=0,
        minRam=0,
        server=nil,
        metadata=        <Fog::Compute::OpenStack::Metadata
          [
            <Fog::Compute::OpenStack::Metadatum
              key="kernel_id",
              value="f443896b-089c-40e7-8712-bb48a676a8de"
            >,
            <Fog::Compute::OpenStack::Metadatum
              key="ramdisk_id",
              value="e21af7e2-a181-403a-84a4-fd9df36cb963"
            >
          ]
        >,
        links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"bookmark"}, {"href"=>"http://localhost:9292/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "type"=>"application/vnd.openstack.image", "rel"=>"alternate"}]
      >,
      <Fog::Compute::OpenStack::Image
        id="e21af7e2-a181-403a-84a4-fd9df36cb963",
        name="cirros-0.3.1-x86_64-uec-ramdisk",
        created_at="2013-07-11T19:59:18Z",
        updated_at="2013-07-11T19:59:18Z",
        progress=100,
        status="ACTIVE",
        minDisk=0,
        minRam=0,
        server=nil,
        metadata=        <Fog::Compute::OpenStack::Metadata
          []
        >,
        links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/images/e21af7e2-a181-403a-84a4-fd9df36cb963", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/e21af7e2-a181-403a-84a4-fd9df36cb963", "rel"=>"bookmark"}, {"href"=>"http://localhost:9292/b5bf8e689bc64844b1d08094a2f2bdd5/images/e21af7e2-a181-403a-84a4-fd9df36cb963", "type"=>"application/vnd.openstack.image", "rel"=>"alternate"}]
      >,
	…

## Get Image

To retrieve individual image:

	service.images.get "821e2b73-5aed-4f9d-aaa7-2f4f297779f3"

This returns an `Fog::Compute::OpenStack::Image` instance:

    <Fog::Compute::OpenStack::Image
    id="821e2b73-5aed-4f9d-aaa7-2f4f297779f3",
    name="cirros-0.3.1-x86_64-uec",
    created_at="2013-07-11T19:59:19Z",
    updated_at="2013-07-11T19:59:20Z",
    progress=100,
    status="ACTIVE",
    minDisk=0,
    minRam=0,
    server=nil,
    metadata=    <Fog::Compute::OpenStack::Metadata
      [
        <Fog::Compute::OpenStack::Metadatum
          key="kernel_id",
          value="f443896b-089c-40e7-8712-bb48a676a8de"
        >,
        <Fog::Compute::OpenStack::Metadatum
          key="ramdisk_id",
          value="e21af7e2-a181-403a-84a4-fd9df36cb963"
        >
      ]
    >,
    links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"bookmark"}, {"href"=>"http://localhost:9292/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "type"=>"application/vnd.openstack.image", "rel"=>"alternate"}]
    >

## List Flavors

To retrieve a list of available flavors:

	service.flavors

This returns a collection of `Fog::Compute::OpenStack::Flavor` models:

    <Fog::Compute::OpenStack::Flavors
    [
      <Fog::Compute::OpenStack::Flavor
        id="1",
        name="m1.tiny",
        ram=512,
        disk=1,
        vcpus=1,
        links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}],
        swap="",
        rxtx_factor=1.0,
        ephemeral=0,
        is_public=true,
        disabled=false
      >,
      <Fog::Compute::OpenStack::Flavor
        id="2",
        name="m1.small",
        ram=2048,
        disk=20,
        vcpus=1,
        links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/2", "rel"=>"bookmark"}],
        swap="",
        rxtx_factor=1.0,
        ephemeral=0,
        is_public=true,
        disabled=false
      >,
	…


## Get Flavor

To retrieve individual flavor:

	service.flavors.get 1

This returns a `Fog::Compute::OpenStack::Flavor` instance:

    <Fog::Compute::OpenStack::Flavor
    id="1",
    name="m1.tiny",
    ram=512,
    disk=1,
    vcpus=1,
    links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}],
    swap="",
    rxtx_factor=1.0,
    ephemeral=0,
    is_public=true,
    disabled=false
    >

## List Servers

To retrieve a list of available  servers:

	service.servers

This returns a collection of `Fog::Compute::OpenStack::Servers` models:

    <Fog::Compute::OpenStack::Servers
        filters={}
        [
          <Fog::Compute::OpenStack::Server
            id="4572529c-0cfc-433e-8dbf-7cc383ed5b7c",
            instance_name=nil,
            addresses={"private"=>[{"OS-EXT-IPS-MAC:mac_addr"=>"fa:16:3e:14:34:b8", "version"=>4, "addr"=>"10.0.0.5", "OS-EXT-IPS:type"=>"fixed"}]},
            flavor={"id"=>"1", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}]},
            host_id="bb705edc279c520d97ad6fbd0b8e75a5c716388616f58e527d0ff633",
            image={"id"=>"821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"bookmark"}]},
            metadata=        <Fog::Compute::OpenStack::Metadata
              []
            >,
            links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/servers/4572529c-0cfc-433e-8dbf-7cc383ed5b7c", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/servers/4572529c-0cfc-433e-8dbf-7cc383ed5b7c", "rel"=>"bookmark"}],
            name="doc-test",
            personality=nil,
            progress=0,
            accessIPv4="",
            accessIPv6="",
            availability_zone="nova",
            user_data_encoded=nil,
            state="ACTIVE",
            created=2013-10-10 18:17:46 UTC,
            updated=2013-10-10 18:17:56 UTC,
            tenant_id="b5bf8e689bc64844b1d08094a2f2bdd5",
            user_id="dbee88bc901b4593867c105b2b1ad15b",
            key_name=nil,
            fault=nil,
            config_drive="",
            os_dcf_disk_config="MANUAL",
            os_ext_srv_attr_host="devstack",
            os_ext_srv_attr_hypervisor_hostname="devstack",
            os_ext_srv_attr_instance_name="instance-00000016",
            os_ext_sts_power_state=1,
            os_ext_sts_task_state=nil,
            os_ext_sts_vm_state="active"
          >,
          …

## Get Server

To return an individual server:

	service.servers.get "4572529c-0cfc-433e-8dbf-7cc383ed5b7c"

This returns a `Fog::Compute::OpenStack::Server` instance:

	<Fog::Compute::OpenStack::Server
            id="4572529c-0cfc-433e-8dbf-7cc383ed5b7c",
            instance_name=nil,
            addresses={"private"=>[{"OS-EXT-IPS-MAC:mac_addr"=>"fa:16:3e:14:34:b8", "version"=>4, "addr"=>"10.0.0.5", "OS-EXT-IPS:type"=>"fixed"}]},
            flavor={"id"=>"1", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}]},
            host_id="bb705edc279c520d97ad6fbd0b8e75a5c716388616f58e527d0ff633",
            image={"id"=>"821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"bookmark"}]},
            metadata=        <Fog::Compute::OpenStack::Metadata
              []
            >,
            links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/servers/4572529c-0cfc-433e-8dbf-7cc383ed5b7c", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/servers/4572529c-0cfc-433e-8dbf-7cc383ed5b7c", "rel"=>"bookmark"}],
            name="doc-test",
            personality=nil,
            progress=0,
            accessIPv4="",
            accessIPv6="",
            availability_zone="nova",
            user_data_encoded=nil,
            state="ACTIVE",
            created=2013-10-10 18:17:46 UTC,
            updated=2013-10-10 18:17:56 UTC,
            tenant_id="b5bf8e689bc64844b1d08094a2f2bdd5",
            user_id="dbee88bc901b4593867c105b2b1ad15b",
            key_name=nil,
            fault=nil,
            config_drive="",
            os_dcf_disk_config="MANUAL",
            os_ext_srv_attr_host="devstack",
            os_ext_srv_attr_hypervisor_hostname="devstack",
            os_ext_srv_attr_instance_name="instance-00000016",
            os_ext_sts_power_state=1,
            os_ext_sts_task_state=nil,
            os_ext_sts_vm_state="active"
          >

## Create Server

If you are interested in creating a server utilizing ssh key authentication, you are recommended to use [bootstrap](#bootstrap) method.

To create a server:

	flavor = service.flavors.first
	image = service.images.first
	server = service.servers.create(:name => 'fog-doc', :flavor_ref => flavor.id, :image_ref => image.id)

**Note**: The `:name`, `:flavor_ref`, and `image_ref` attributes are required for server creation.

This will return a `Fog::Compute::OpenStack::Server` instance:

	<Fog::Compute::OpenStack::Server
    id="81746324-94ab-44fb-9aa9-ee0b4d95fa34",
    instance_name=nil,
    addresses=nil,
    flavor=nil,
    host_id=nil,
    image=nil,
    metadata=    <Fog::Compute::OpenStack::Metadata
      []
    >,
    links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/servers/81746324-94ab-44fb-9aa9-ee0b4d95fa34", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/servers/81746324-94ab-44fb-9aa9-ee0b4d95fa34", "rel"=>"bookmark"}],
    name="fog-doc",
    personality=nil,
    progress=nil,
    accessIPv4=nil,
    accessIPv6=nil,
    availability_zone=nil,
    user_data_encoded=nil,
    state=nil,
    created=nil,
    updated=nil,
    tenant_id=nil,
    user_id=nil,
    key_name=nil,
    fault=nil,
    config_drive=nil,
    os_dcf_disk_config="MANUAL",
    os_ext_srv_attr_host=nil,
    os_ext_srv_attr_hypervisor_hostname=nil,
    os_ext_srv_attr_instance_name=nil,
    os_ext_sts_power_state=nil,
    os_ext_sts_task_state=nil,
    os_ext_sts_vm_state=nil
  >

Notice that your server contains several `nil` attributes. To see the latest status, reload the instance as follows:

	server.reload

You can see that the server is currently being built:

    <Fog::Compute::OpenStack::Server
    id="5f50aeff-a745-4cbc-9f8b-0356142e6f95",
    instance_name=nil,
    addresses={"private"=>[{"OS-EXT-IPS-MAC:mac_addr"=>"fa:16:3e:71:0d:c4", "version"=>4, "addr"=>"10.0.0.2", "OS-EXT-IPS:type"=>"fixed"}]},
    flavor={"id"=>"1", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/flavors/1", "rel"=>"bookmark"}]},
    host_id="bb705edc279c520d97ad6fbd0b8e75a5c716388616f58e527d0ff633",
    image={"id"=>"821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "links"=>[{"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/images/821e2b73-5aed-4f9d-aaa7-2f4f297779f3", "rel"=>"bookmark"}]},
    metadata=    <Fog::Compute::OpenStack::Metadata
      []
    >,
    links=[{"href"=>"http://localhost:8774/v2/b5bf8e689bc64844b1d08094a2f2bdd5/servers/5f50aeff-a745-4cbc-9f8b-0356142e6f95", "rel"=>"self"}, {"href"=>"http://localhost:8774/b5bf8e689bc64844b1d08094a2f2bdd5/servers/5f50aeff-a745-4cbc-9f8b-0356142e6f95", "rel"=>"bookmark"}],
    name="fog-doc",
    personality=nil,
    progress=0,
    accessIPv4="",
    accessIPv6="",
    availability_zone="nova",
    user_data_encoded=nil,
    state="BUILD",
    created=2014-01-09 19:43:52 UTC,
    updated=2014-01-09 19:43:58 UTC,
    tenant_id="b5bf8e689bc64844b1d08094a2f2bdd5",
    user_id="dbee88bc901b4593867c105b2b1ad15b",
    key_name=nil,
    fault=nil,
    config_drive="",
    os_dcf_disk_config="MANUAL",
    os_ext_srv_attr_host="devstack",
    os_ext_srv_attr_hypervisor_hostname="devstack",
    os_ext_srv_attr_instance_name="instance-00000018",
    os_ext_sts_power_state=0,
    os_ext_sts_task_state="spawning",
    os_ext_sts_vm_state="building"
  >

You will be unable to perform any actions to this server until it reaches an `ACTIVE` state. Since this is true for most server actions, Fog provides the convenience method `wait_for`.

Fog can wait for the server to become ready as follows:

	server.wait_for { ready? }

**Note**: The `Fog::Compute::OpenStack::Server` instance returned from the create method contains a `password` attribute. The `password` attribute will NOT be present in subsequent retrievals either through `service.servers` or `service.servers.get my_server_id`.

### Additional Parameters

The `create` method also supports the following key values:

<table>
	<tr>
		<th>Key</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>:metadata</td>
		<td>Hash containing server metadata.</td>
	</tr>
	<tr>
		<td>:personality</td>
		<td>Array of files to be injected onto the server. Please refer to the Fog <a href="http://rubydoc.info/github/fog/fog/Fog/Compute/OpenStack/Server:personality">personality </a> API documentation for further information.</td>
	</tr>
</table>

## Bootstrap

In addition to the `create` method, Fog provides a `bootstrap` method which creates a server and then performs the following actions via ssh:

1. Create `ROOT_USER/.ssh/authorized_keys` file using the ssh key specified in `:public_key_path`.
2. Lock password for root user using `passwd -l root`.
3. Create `ROOT_USER/attributes.json` file with the contents of `server.attributes`.
4. Create `ROOT_USER/metadata.json` file with the contents of `server.metadata`.

**Note**: Unlike the `create` method, `bootstrap` is blocking method call. If non-blocking behavior is desired, developers should use the `:personality` parameter on the `create` method.

The following example demonstrates bootstraping a server:

	service.servers.bootstrap :name => 'bootstrap-server',
	:flavor_id => service.flavors.first.id,
	:image_id => service.images.find {|img| img.name =~ /Ubuntu/}.id,
	:public_key_path => '~/.ssh/fog_rsa.pub',
	:private_key_path => '~/.ssh/fog_rsa'

**Note**: The `:name`, `:flavor_ref`, `:image_ref`, `:public_key_path`, `:private_key_path` are required for the `bootstrap` method.

The `bootstrap` method uses the same additional parameters as the `create` method. Refer to the [Additional Parameters](#additional-parameters) section for more information.

## SSH

Once a server has been created and set up for ssh key authentication, fog can execute remote commands as follows:

	result = server.ssh ['pwd']

This will return the following:

	[#<Fog::SSH::Result:0x1108241d0 @stderr="", @status=0, @stdout="/root\r\n", @command="pwd">]

**Note**: SSH key authentication can be set up using `bootstrap` method or by using the `:personality` attribute on the `:create` method. See [Bootstrap](#bootstrap) or [Create Server](#create-server) for more information.

## Delete Server

To delete a server:

	server.destroy

**Note**: The server is not immediately destroyed, but it does occur shortly there after.

## Change Admin Password

To change the administrator password:

	server.change_password "superSecure"

## Reboot

To perform a soft reboot:

	server.reboot

To perform a hard reboot:

	server.reboot 'HARD'

## Rebuild

Rebuild removes all data on the server and replaces it with the specified image. The id and all IP addresses remain the same.

The rebuild method has the following method signature:

    def rebuild(image_ref, name, admin_pass=nil, metadata=nil, personality=nil)

A basic server build is as follows:

	image = service.images.first
	server.rebuild(image.id, name)

## Resize

Resizing a server allows you to change the resources dedicated to the server.

To resize a server:

	flavor = service.flavor[2]
	server.resize flavor.id

During the resize process the server will have a state of `RESIZE`. Once a server has completed resizing it will be in a `VERIFY_RESIZE` state.

You can use Fog's `wait_for` method to wait for this state as follows:

	server.wait_for { server.status == 'VERIFY_RESIZE' }


In this case, `wait_for` is waiting for the server to become `VERIFY_READY` and will raise an exception if we enter an `ACTIVE` or `ERROR` state.

Once a server enters the `VERIFY_RESIZE` we will need to call `confirm_resize` to confirm the server was properly resized or `revert_resize` to rollback to the old size/flavor.

**Note:** A server will automatically confirm resize after 24 hours.

To confirm resize:

	server.confirm_resize

To revert to previous size/flavor:

	server.revert_resize

## Create Image

To create an image of your server:

    response = server.create_image "back-image-#{server.name}", :metadata => { :environment => 'development' }

You can use the second parameter to specify image metadata. This is an optional parameter.`

During the imaging process, the image state will be `SAVING`. The image is ready for use when when state `ACTIVE` is reached. Fog can use `wait_for` to wait for an active state as follows:

    image_id = response.body["image"]["id"]
    image = service.images.get image_id
	image.wait_for { ready? }

## List Attached Volumes

To list Cloud Block Volumes attached to server:

	server.volume_attachments

## Attach Volume

To attach volume using the volume id:

	server.attach_volume "0e7a706c-340d-48b3-802d-192850387f93", "/dev/xvdb"

If the volume id is unknown you can look it up as follows:

	volume = service.volumes.first
	server.attach_volume volume.id, "/dev/xvdb"

**Note** Valid device names are `/dev/xvd[a-p]`.

## Detach Volume

To detach a volume:

    server.detach_volume volume.id

## Examples

Example code using Compute can be found [here](https://github.com/fog/fog/tree/master/lib/fog/openstack/examples/compute).

## Additional Resources

* [OpenStack Compute API](http://docs.openstack.org/api/openstack-compute/2/content/)
* [more resources and feedback](common/resources.md)
