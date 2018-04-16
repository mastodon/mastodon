# Storage

This document explains how to get started using OpenStack Swift with Fog.


## Starting irb console

Start by executing the following command:

irb

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

Next, create a connection to Swift:

```ruby
service = Fog::Storage::OpenStack.new({
  :openstack_username  => USERNAME,      # Your OpenStack Username
  :openstack_api_key   => PASSWORD,      # Your OpenStack Password
  :openstack_auth_url  => 'http://YOUR_OPENSTACK_ENDPOINT:PORT/v2.0/tokens',
  :connection_options  => {}
})
```

Read more about the [Optional Connection Parameters](common/connection_params.md)

Alternative regions are specified using the key `:openstack_region `. A list of regions available for Swift can be found by executing the following:

### Optional Service Parameters

The Storage service supports the following additional parameters:

<table>
<tr>
<th>Key</th>
<th>Description</th>
</tr>
<tr>
<td>:persistent</td>
<td>If set to true, the service will use a persistent connection.</td>
</tr>
<tr>
<td>:openstack_service_name</td>
<td></td>
</tr>
<tr>
<td>:openstack_service_type</td>
<td></td>
</tr>
<tr>
<td>:openstack_tenant</td>
<td></td>
</tr>
<tr>
<td>:openstack_region</td>
<td></td>
</tr>
<tr>
<td>:openstack_temp_url_key</td>
<td></td>
</tr>
</table>

## Fog Abstractions

Fog provides both a **model** and **request** abstraction. The request abstraction provides the most efficient interface and the model abstraction wraps the request abstraction to provide a convenient `ActiveModel` like interface.

### Request Layer

The Fog::Storage object supports a number of methods that wrap individual HTTP requests to the Swift API.

To see a list of requests supported by the storage service:

service.requests

This returns:

[:copy_object, :delete_container, :delete_object, :delete_multiple_objects, :delete_static_large_object, :get_container, :get_containers, :get_object, :get_object_http_url, :get_object_https_url, :head_container, :head_containers, :head_object, :put_container, :put_object, :put_object_manifest, :put_dynamic_obj_manifest, :put_static_obj_manifest, :post_set_meta_temp_url_key]

#### Example Request

To request a view account details:

```ruby
response = service.head_containers
```

This returns in the following `Excon::Response`:

```
#<Excon::Response:0x10283fc68 @headers={"X-Account-Bytes-Used"=>"2563554", "Date"=>"Thu, 21 Feb 2013 21:57:02 GMT", "X-Account-Meta-Temp-Url-Key"=>"super_secret_key", "X-Timestamp"=>"1354552916.82056", "Content-Length"=>"0", "Content-Type"=>"application/json; charset=utf-8", "X-Trans-Id"=>"txe934924374a744c8a6c40dd8f29ab94a", "Accept-Ranges"=>"bytes", "X-Account-Container-Count"=>"7", "X-Account-Object-Count"=>"5"}, @status=204, @body="">
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

This will return:

```
{"X-Account-Bytes-Used"=>"2563554", "Date"=>"Thu, 21 Feb 2013 21:57:02 GMT", "X-Account-Meta-Temp-Url-Key"=>"super_secret_key", "X-Timestamp"=>"1354552916.82056", "Content-Length"=>"0", "Content-Type"=>"application/json; charset=utf-8", "X-Trans-Id"=>"txe934924374a744c8a6c40dd8f29ab94a", "Accept-Ranges"=>"bytes", "X-Account-Container-Count"=>"7", "X-Account-Object-Count"=>"5"}
```

To learn more about `Fog::Storage` request methods refer to [rdoc](http://rubydoc.info/gems/fog/Fog/Storage/OpenStack/Real). To learn more about Excon refer to [Excon GitHub repo](https://github.com/geemus/excon).

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

**Note:** Fog sometimes refers to Swift containers as directories.

## List Directories

To retrieve a list of directories:

```ruby
service.directories
```

This returns a collection of `Fog::Storage::OpenStack::Directory` models:

## Get Directory

To retrieve a specific directory:

```ruby
service.directories.get "blue"
```

This returns a `Fog::Storage::OpenStack::Directory` instance:

## Create Directory

To create a directory:

```ruby
service.directories.create :key => 'backups'
```

### Additional Parameters

The `create` method also supports the following key values:

<table>
<tr>
<th>Key</th>
<th>Description</th>
</tr>
<tr>
<td>:metadata</td>
<td>Hash containing directory metadata.</td>
</tr>
</table>


## Delete Directory

To delete a directory:

```ruby
directory.destroy
```

**Note**: Directory must be empty before it can be deleted.


## Directory URL

To get a directory's URL:

```ruby
directory.public_url
```

## List Files

To list files in a directory:

```ruby
directory.files
```

**Note**: File contents is not downloaded until `body` attribute is called.

## Upload Files

To upload a file into a directory:

```ruby
file = directory.files.create :key => 'space.jpg', :body => File.open "space.jpg"
```

**Note**: For files larger than 5 GB please refer to the [Upload Large Files](#upload_large_files) section.

### Additional Parameters

The `create` method also supports the following key values:

<table>
<tr>
<th>Key</th>
<th>Description</th>
</tr>
<tr>
<td>:content_type</td>
<td>The content type of the object. Cloud Files will attempt to auto detect this value if omitted.</td>
</tr>
<tr>
<td>:access_control_allow_origin</td>
<td>URLs can make Cross Origin Requests. Format is http://www.example.com. Separate URLs with a space. An asterisk (*) allows all. Please refer to <a href="http://docs.rackspace.com/files/api/v1/cf-devguide/content/CORS_Container_Header-d1e1300.html">CORS Container Headers</a> for more information.</td>
</tr>
<tr>
<td>:origin</td>
<td>The origin is the URI of the object's host.</td>
</tr>
<tr>
<td>:etag</td>
<td>The MD5 checksum of your object's data. If specified, Cloud Files will validate the integrity of the uploaded object.</td>
</tr>
<tr>
<td>:metadata</td>
<td>Hash containing file metadata.</td>
</tr>
</table>

## Upload Large Files

Swift requires files larger than 5 GB (the Swift default limit) to be uploaded into segments along with an accompanying manifest file. All of the segments must be uploaded to the same container.

```ruby
	SEGMENT_LIMIT = 5368709119.0  # 5GB -1
	BUFFER_SIZE = 1024 * 1024 # 1MB

	File.open(file_name) do |file|
	  segment = 0
	  until file.eof?
	    segment += 1
	    offset = 0

	    # upload segment to cloud files
	    segment_suffix = segment.to_s.rjust(10, '0')
	    service.put_object("my_container", "large_file/#{segment_suffix}", nil) do
	      if offset <= SEGMENT_LIMIT - BUFFER_SIZE
	        buf = file.read(BUFFER_SIZE).to_s
	        offset += buf.size
	        buf
	      else
	        ''
	      end
	    end
	  end
	end

	# write manifest file
	service.put_object_manifest("my_container", "large_file", 'X-Object-Manifest' => "my_container/large_file/")
```

Segmented files are downloaded like ordinary files. See [Download Files](#download-files) section for more information.

## Download Files

The most efficient way to download files from a private or public directory is as follows:

```ruby
File.open('downloaded-file.jpg', 'w') do | f |
  directory.files.get("my_big_file.jpg") do | data, remaining, content_length |
    f.syswrite data
  end
end
```

This will download and save the file in 1 MB chunks. The chunk size can be changed by passing the parameter `:chunk_size` into the `:connection_options` hash in the service constructor.

**Note**: The `body` attribute of file will be empty if a file has been downloaded using this method.

If a file object has already been loaded into memory, you can save it as follows:

```ruby
File.open('germany.jpg', 'w') {|f| f.write(file_object.body) }
```

**Note**: This method is more memory intensive as the entire object is loaded into memory before saving the file as in the example above.


## File URL

To get a file's URL:

```ruby
file.public_url
```

## Metadata

You can access metadata as an attribute on `Fog::Storage::Rackspace::File`.

```ruby
file.metadata[:environment]
```

File metadata is set when the file is saved:

```ruby
file.save
```

Metadata is reloaded when directory or file is reloaded:

```ruby
file.reload
```

## Copy File

Cloud Files supports copying files. To copy files into a container named "trip" with a name of "europe.jpg" do the following:

```ruby
file.copy("trip", "europe.jpg")
```

To move or rename a file, perform a copy operation and then delete the old file:

```ruby
file.copy("trip", "germany.jpg")
file.destroy
```

## Delete File

To delete a file:

```ruby
file.destroy
```

## Additional Resources

* [Swift API](http://docs.openstack.org/api/openstack-object-storage/1.0/content/index.html)
* [more resources and feedback](common/resources.md)
