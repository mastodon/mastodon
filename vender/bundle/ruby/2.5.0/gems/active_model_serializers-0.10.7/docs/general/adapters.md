[Back to Guides](../README.md)

# Adapters

ActiveModelSerializers offers the ability to configure which adapter
to use both globally and/or when serializing (usually when rendering).

The global adapter configuration is set on [`ActiveModelSerializers.config`](configuration_options.md).
It should be set only once, preferably at initialization.

For example:

```ruby
ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi
```

or

```ruby
ActiveModelSerializers.config.adapter = :json_api
```

or

```ruby
ActiveModelSerializers.config.adapter = :json
```

The local adapter option is in the format `adapter: adapter`, where `adapter` is
any of the same values as set globally.

The configured adapter can be set as a symbol, class, or class name, as described in
[Advanced adapter configuration](adapters.md#advanced-adapter-configuration).

The `Attributes` adapter does not include a root key. It is just the serialized attributes.

Use either the `JSON` or `JSON API` adapters if you want the response document to have a root key.

***IMPORTANT***: Adapter configuration has *no effect* on a serializer instance
being used directly. That is, `UserSerializer.new(user).as_json` will *always*
behave as if the adapter were the 'Attributes' adapter. See [Outside Controller
Usage](../howto/outside_controller_use.md) for more details on recommended
usage.

## Built in Adapters

### Attributes - Default

It's the default adapter, it generates a json response without a root key.
Doesn't follow any specific convention.

##### Example output

```json
{
  "title": "Title 1",
  "body": "Body 1",
  "publish_at": "2020-03-16T03:55:25.291Z",
  "author": {
    "first_name": "Bob",
    "last_name": "Jones"
  },
  "comments": [
    {
      "body": "cool"
    },
    {
      "body": "awesome"
    }
  ]
}
```

### JSON

The json response is always rendered with a root key.

The root key can be overridden by:
* passing the `root` option in the render call. See details in the [Rendering Guides](rendering.md#overriding-the-root-key).
* setting the `type` of the serializer. See details in the [Serializers Guide](serializers.md#type).

Doesn't follow any specific convention.

##### Example output

```json
{
  "post": {
    "title": "Title 1",
    "body": "Body 1",
    "publish_at": "2020-03-16T03:55:25.291Z",
    "author": {
      "first_name": "Bob",
      "last_name": "Jones"
    },
    "comments": [{
      "body": "cool"
    }, {
      "body": "awesome"
    }]
  }
}
```

### JSON API

This adapter follows **version 1.0** of the [format specified](../jsonapi/schema.md) in
[jsonapi.org/format](http://jsonapi.org/format).

##### Example output

```json
{
  "data": {
    "id": "1337",
    "type": "posts",
    "attributes": {
      "title": "Title 1",
      "body": "Body 1",
      "publish-at": "2020-03-16T03:55:25.291Z"
    },
    "relationships": {
      "author": {
        "data": {
          "id": "1",
          "type": "authors"
        }
      },
      "comments": {
        "data": [{
          "id": "7",
          "type": "comments"
        }, {
          "id": "12",
          "type": "comments"
        }]
      }
    },
    "links": {
      "post-authors": "https://example.com/post_authors"
    },
    "meta": {
      "rating": 5,
      "favorite-count": 10
    }
  }
}
```

### Include option

Which [serializer associations](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/serializers.md#associations) are rendered can be specified using the `include` option. The option usage is consistent with [the include option in the JSON API spec](http://jsonapi.org/format/#fetching-includes), and is available in all adapters.

Example of the usage:
```ruby
  render json: @posts, include: ['author', 'comments', 'comments.author']
  # or
  render json: @posts, include: 'author,comments,comments.author'
```

The format of the `include` option can be either:

- a String composed of a comma-separated list of [relationship paths](http://jsonapi.org/format/#fetching-includes).
- an Array of Symbols and Hashes.
- a mix of both.

An empty string or an empty array will prevent rendering of any associations.

In addition, two types of wildcards may be used:

- `*` includes one level of associations.
- `**` includes all recursively.

These can be combined with other paths.

```ruby
  render json: @posts, include: '**' # or '*' for a single layer
```


The following would render posts and include:

- the author
- the author's comments, and
- every resource referenced by the author's comments (recursively).

It could be combined, like above, with other paths in any combination desired.

```ruby
  render json: @posts, include: 'author.comments.**'
```

**Note:** Wildcards are ActiveModelSerializers-specific, they are not part of the JSON API spec.

The default include for the JSON API adapter is no associations. The default for the JSON and Attributes adapters is all associations.

For the JSON API adapter associated resources will be gathered in the `"included"` member. For the JSON and Attributes
adapters associated resources will be rendered among the other attributes.

Only for the JSON API adapter you can specify, which attributes of associated resources will be rendered. This feature
is called [sparse fieldset](http://jsonapi.org/format/#fetching-sparse-fieldsets):

```ruby
  render json: @posts, include: 'comments', fields: { comments: ['content', 'created_at'] }
```

##### Security Considerations

Since the included options may come from the query params (i.e. user-controller):

```ruby
  render json: @posts, include: params[:include]
```

The user could pass in `include=**`.

We recommend filtering any user-supplied includes appropriately.

## Advanced adapter configuration

### Registering an adapter

The default adapter can be configured, as above, to use any class given to it.

An adapter may also be specified, e.g. when rendering, as a class or as a symbol.
If a symbol, then the adapter must be, e.g. `:great_example`,
`ActiveModelSerializers::Adapter::GreatExample`, or registered.

There are two ways to register an adapter:

1) The simplest, is to subclass `ActiveModelSerializers::Adapter::Base`, e.g. the below will
register the `Example::UsefulAdapter` as `"example/useful_adapter"`.

```ruby
module Example
  class UsefulAdapter < ActiveModelSerializers::Adapter::Base
  end
end
```

You'll notice that the name it registers is the underscored namespace and class.

Under the covers, when the `ActiveModelSerializers::Adapter::Base` is subclassed, it registers
the subclass as `register("example/useful_adapter", Example::UsefulAdapter)`

2) Any class can be registered as an adapter by calling `register` directly on the
`ActiveModelSerializers::Adapter` class. e.g., the below registers `MyAdapter` as
`:special_adapter`.

```ruby
class MyAdapter; end
ActiveModelSerializers::Adapter.register(:special_adapter, MyAdapter)
```

### Looking up an adapter

| Method | Return value |
| :------------ |:---------------|
| `ActiveModelSerializers::Adapter.adapter_map` | A Hash of all known adapters `{ adapter_name => adapter_class }` |
| `ActiveModelSerializers::Adapter.adapters` | A (sorted) Array of all known `adapter_names` |
| `ActiveModelSerializers::Adapter.lookup(name_or_klass)` |  The `adapter_class`, else raises an `ActiveModelSerializers::Adapter::UnknownAdapter` error |
| `ActiveModelSerializers::Adapter.adapter_class(adapter)` | Delegates to `ActiveModelSerializers::Adapter.lookup(adapter)` |
| `ActiveModelSerializers::Adapter.configured_adapter` | A convenience method for `ActiveModelSerializers::Adapter.lookup(config.adapter)` |

The registered adapter name is always a String, but may be looked up as a Symbol or String.
Helpfully, the Symbol or String is underscored, so that `get(:my_adapter)` and `get("MyAdapter")`
may both be used.

For more information, see [the Adapter class on GitHub](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/adapter.rb)
