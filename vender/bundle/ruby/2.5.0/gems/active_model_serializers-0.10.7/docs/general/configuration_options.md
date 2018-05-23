[Back to Guides](../README.md)

# Configuration Options

The following configuration options can be set on
`ActiveModelSerializers.config`, preferably inside an initializer.

## General

##### adapter

The [adapter](adapters.md) to use.

Possible values:

- `:attributes` (default)
- `:json`
- `:json_api`

##### serializer_lookup_enabled

Enable automatic serializer lookup.

Possible values:

- `true` (default)
- `false`

When `false`, serializers must be explicitly specified.

##### key_transform

The [key transform](key_transforms.md) to use.


| Option | Result |
|----|----|
| `:camel` | ExampleKey |
| `:camel_lower` | exampleKey |
| `:dash` | example-key |
| `:unaltered` | the original, unaltered key |
| `:underscore` | example_key |
| `nil` | use the adapter default |

Each adapter has a default key transform configured:

| Adapter | Default Key Transform |
|----|----|
| `Attributes` | `:unaltered` |
| `Json` | `:unaltered` |
| `JsonApi` | `:dash` |

`config.key_transform` is a global override of the adapter default. Adapters
still prefer the render option `:key_transform` over this setting.

*NOTE: Key transforms can be expensive operations. If key transforms are unnecessary for the
application, setting `config.key_transform` to `:unaltered` will provide a performance boost.*

##### default_includes

What relationships to serialize by default.  Default: `'*'`, which includes one level of related
objects. See [includes](adapters.md#included) for more info.


##### serializer_lookup_chain

Configures how serializers are searched for. By default, the lookup chain is

```ruby
ActiveModelSerializers::LookupChain::DEFAULT
```

which is shorthand for

```ruby
[
  ActiveModelSerializers::LookupChain::BY_PARENT_SERIALIZER,
  ActiveModelSerializers::LookupChain::BY_NAMESPACE,
  ActiveModelSerializers::LookupChain::BY_RESOURCE_NAMESPACE,
  ActiveModelSerializers::LookupChain::BY_RESOURCE
]
```

Each of the array entries represent a proc. A serializer lookup proc will be yielded 3 arguments. `resource_class`, `serializer_class`, and `namespace`.

Note that:
 - `resource_class` is the class of the resource being rendered
 - by default `serializer_class` is `ActiveModel::Serializer`
   - for association lookup it's the "parent" serializer
 - `namespace` correspond to either the controller namespace or the [optionally] specified [namespace render option](./rendering.md#namespace)

An example config could be:

```ruby
ActiveModelSerializers.config.serializer_lookup_chain = [
  lambda do |resource_class, serializer_class, namespace|
    "API::#{namespace}::#{resource_class}"
  end
]
```

If you simply want to add to the existing lookup_chain. Use `unshift`.

```ruby
ActiveModelSerializers.config.serializer_lookup_chain.unshift(
  lambda do |resource_class, serializer_class, namespace|
    # ...
  end
)
```

See [lookup_chain.rb](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/lookup_chain.rb) for further explanations and examples.

## JSON API

##### jsonapi_resource_type

Sets whether the [type](http://jsonapi.org/format/#document-resource-identifier-objects)
of the resource should be `singularized` or `pluralized` when it is not
[explicitly specified by the serializer](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/serializers.md#type)

Possible values:

- `:singular`
- `:plural` (default)

##### jsonapi_namespace_separator

Sets separator string for namespaced models to render `type` attribute.


| Separator | Example: Admin::User |
|----|----|
| `'-'` (default) | 'admin-users'
| `'--'` (recommended) | 'admin--users'

See [Recommendation for dasherizing (kebab-case-ing) namespaced object, such as `Admin::User`](https://github.com/json-api/json-api/issues/850)
for more discussion.

##### jsonapi_include_toplevel_object

Include a [top level jsonapi member](http://jsonapi.org/format/#document-jsonapi-object)
in the response document.

Possible values:

- `true`
- `false` (default)

##### jsonapi_version

The latest version of the spec to which the API conforms.

Default: `'1.0'`.

*Used when `jsonapi_include_toplevel_object` is `true`*

##### jsonapi_toplevel_meta

Optional top-level metadata. Not included if empty.

Default: `{}`.

*Used when `jsonapi_include_toplevel_object` is `true`*

##### jsonapi_use_foreign_key_on_belongs_to_relationship

When true, the relationship will determine its resource object identifier
without calling the association or its serializer.  This can be useful when calling
the association object is triggering unnecessary queries.

For example, if a `comment` belongs to a `post`, and the comment
uses the foreign key `post_id`, we can determine the resource object
identifier `id` as `comment.post_id` and the `type` from the association options.
Or quite simply, it behaves as `belongs_to :post, type: :posts, foreign_key: :post_id`.

Note: This option has *no effect* on polymorphic associations as we cannot reliably
determine the associated object's type without instantiating it.

Default: `false`.

## Hooks

To run a hook when ActiveModelSerializers is loaded, use
`ActiveSupport.on_load(:action_controller) do end`
