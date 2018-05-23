[Back to Guides](../README.md)

# Rendering

### Implicit Serializer

In your controllers, when you use `render :json`, Rails will now first search
for a serializer for the object and use it if available.

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    render json: @post
  end
end
```

In this case, Rails will look for a serializer named `PostSerializer`, and if
it exists, use it to serialize the `Post`.

### Explicit Serializer

If you wish to use a serializer other than the default, you can explicitly pass it to the renderer.

#### 1. For a resource:

```ruby
  render json: @post, serializer: PostPreviewSerializer
```

#### 2. For a resource collection:

Specify the serializer for each resource with `each_serializer`

```ruby
render json: @posts, each_serializer: PostPreviewSerializer
```

The default serializer for collections is `CollectionSerializer`.

Specify the collection serializer with the `serializer` option.

```ruby
render json: @posts, serializer: CollectionSerializer, each_serializer: PostPreviewSerializer
```

## Serializing non-ActiveRecord objects

See [README](../../README.md#what-does-a-serializable-resource-look-like)

## SerializableResource options

See [README](../../README.md#activemodelserializersserializableresource)

### adapter_opts

#### fields

If you are using `json` or `attributes` adapter
```ruby
render json: @user, fields: [:access_token]
```

See [Fields](fields.md) for more information.

#### adapter

This option lets you explicitly set the adapter to be used by passing a registered adapter. Your options are `:attributes`, `:json`, and `:json_api`.

```
ActiveModel::Serializer.config.adapter = :json_api
```

#### key_transform

```render json: posts, each_serializer: PostSerializer, key_transform: :camel_lower```

See [Key Transforms](key_transforms.md) for more information.

#### meta

A `meta` member can be used to include non-standard meta-information. `meta` can
be utilized in several levels in a response.

##### Top-level

To set top-level `meta` in a response, specify it in the `render` call.

```ruby
render json: @post, meta: { total: 10 }
```

The key can be customized using `meta_key` option.

```ruby
render json: @post, meta: { total: 10 }, meta_key: "custom_meta"
```

`meta` will only be included in your response if you are using an Adapter that
supports `root`, e.g., `JsonApi` and `Json` adapters. The default adapter,
`Attributes` does not have `root`.


##### Resource-level

To set resource-level `meta` in a response, define meta in a serializer with one
of the following methods:

As a single, static string.

```ruby
meta stuff: 'value'
```

As a block containing a Hash.

```ruby
meta do
  {
    rating: 4,
    comments_count: object.comments.count
  }
end
```


#### links

If you wish to use Rails url helpers for link generation, e.g., `link(:resources) { resources_url }`, ensure your application sets
`Rails.application.routes.default_url_options`.

##### Top-level

JsonApi supports a [links object](http://jsonapi.org/format/#document-links) to be specified at top-level, that you can specify in the `render`:

```ruby
  links_object = {
    href: "http://example.com/api/posts",
    meta: {
      count: 10
    }
  }
  render json: @posts, links: links_object
```

That's the result:

```json
{
  "data": [
    {
      "type": "posts",
      "id": "1",
      "attributes": {
        "title": "JSON API is awesome!",
        "body": "You should be using JSON API",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "href": "http://example.com/api/posts",
    "meta": {
      "count": 10
    }
  }
}
```

This feature is specific to JsonApi, so you have to use the use the [JsonApi Adapter](adapters.md#jsonapi)


##### Resource-level

In your serializer, define each link in one of the following methods:

As a static string

```ruby
link :link_name, 'https://example.com/resource'
```

As a block to be evaluated. When using Rails, URL helpers are available.
Ensure your application sets `Rails.application.routes.default_url_options`.

```ruby
link :link_name_ do
  "https://example.com/resource/#{object.id}"
end

link(:link_name) { "https://example.com/resource/#{object.id}" }

link(:link_name) { resource_url(object) }

link(:link_name) { url_for(controller: 'controller_name', action: 'index', only_path: false) }

```

### serializer_opts

#### include

See [Adapters: Include Option](/docs/general/adapters.md#include-option).

#### Overriding the root key

Overriding the resource root only applies when using the JSON adapter.

Normally, the resource root is derived from the class name of the resource being serialized.
e.g. `UserPostSerializer.new(UserPost.new)` will be serialized with the root `user_post` or `user_posts` according the adapter collection pluralization rules.

When using the JSON adapter in your initializer (ActiveModelSerializers.config.adapter = :json), or passing in the adapter in your render call, you can specify the root by passing it as an argument to `render`. For example:

```ruby
  render json: @user_post, root: "admin_post", adapter: :json
```

This will be rendered as:
```json
  {
    "admin_post": {
      "title": "how to do open source"
    }
  }
```
Note: the `Attributes` adapter (default) does not include a resource root. You also will not be able to create a single top-level root if you are using the :json_api adapter.

#### namespace

The namespace for serializer lookup is based on the controller.

To configure the implicit namespace, in your controller, create a before filter

```ruby
before_action do
  self.namespace_for_serializer = Api::V2
end
```

`namespace` can also be passed in as a render option:


```ruby
@post = Post.first
render json: @post, namespace: Api::V2
```

This tells the serializer lookup to check for the existence of `Api::V2::PostSerializer`, and if any relations are rendered with `@post`, they will also utilize the `Api::V2` namespace.  

The `namespace` can be any object whose namespace can be represented by string interpolation (i.e. by calling to_s)
- Module `Api::V2`
- String `'Api::V2'`
- Symbol `:'Api::V2'`

Note that by using a string and symbol, Ruby will assume the namespace is defined at the top level.


#### serializer

Specify which serializer to use if you want to use a serializer other than the default.

For a single resource:

```ruby
@post = Post.first
render json: @post, serializer: SpecialPostSerializer
```

To specify which serializer to use on individual items in a collection (i.e., an `index` action), use `each_serializer`:

```ruby
@posts = Post.all
render json: @posts, each_serializer: SpecialPostSerializer
```

#### scope

See [Serializers: Scope](/docs/general/serializers.md#scope).

#### scope_name

See [Serializers: Scope](/docs/general/serializers.md#scope).

## Using a serializer without `render`

See [Usage outside of a controller](../howto/outside_controller_use.md#serializing-before-controller-render).

## Pagination

See [How to add pagination links](../howto/add_pagination_links.md).
