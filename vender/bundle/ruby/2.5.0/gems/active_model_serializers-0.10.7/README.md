# ActiveModelSerializers

<table>
  <tr>
    <td>Build Status</td>
    <td>
      <a href="https://travis-ci.org/rails-api/active_model_serializers"><img src="https://travis-ci.org/rails-api/active_model_serializers.svg?branch=master" alt="Build Status" ></a>
      <a href="https://ci.appveyor.com/project/joaomdmoura/active-model-serializers/branch/master"><img src="https://ci.appveyor.com/api/projects/status/x6xdjydutm54gvyt/branch/master?svg=true" alt="Build status"></a>
    </td>
  </tr>
  <tr>
    <td>Code Quality</td>
    <td>
      <a href="https://codeclimate.com/github/rails-api/active_model_serializers"><img src="https://codeclimate.com/github/rails-api/active_model_serializers/badges/gpa.svg" alt="Code Quality"></a>
      <a href="https://codebeat.co/projects/github-com-rails-api-active_model_serializers"><img src="https://codebeat.co/badges/a9ab35fa-8b5a-4680-9d4e-a81f9a55ebcd" alt="codebeat" ></a>
      <a href="https://codeclimate.com/github/rails-api/active_model_serializers/coverage"><img src="https://codeclimate.com/github/rails-api/active_model_serializers/badges/coverage.svg" alt="Test Coverage"></a>
    </td>
  </tr>
  <tr>
    <td>Issue Stats</td>
    <td>
      <a href="https://github.com/rails-api/active_model_serializers/pulse/monthly">Pulse</a>
    </td>
  </tr>
</table>

## About

ActiveModelSerializers brings convention over configuration to your JSON generation.

ActiveModelSerializers works through two components: **serializers** and **adapters**.

Serializers describe _which_ attributes and relationships should be serialized.

Adapters describe _how_ attributes and relationships should be serialized.

SerializableResource co-ordinates the resource, Adapter and Serializer to produce the
resource serialization. The serialization has the `#as_json`, `#to_json` and `#serializable_hash`
methods used by the Rails JSON Renderer. (SerializableResource actually delegates
these methods to the adapter.)

By default ActiveModelSerializers will use the **Attributes Adapter** (no JSON root).
But we strongly advise you to use **JsonApi Adapter**, which
follows 1.0 of the format specified in [jsonapi.org/format](http://jsonapi.org/format).
Check how to change the adapter in the sections below.

`0.10.x` is **not** backward compatible with `0.9.x` nor `0.8.x`.

`0.10.x` is based on the `0.8.0` code, but with a more flexible
architecture. We'd love your help. [Learn how you can help here.](CONTRIBUTING.md)

## Installation

Add this line to your application's Gemfile:

```
gem 'active_model_serializers', '~> 0.10.0'
```

And then execute:

```
$ bundle
```

## Getting Started

See [Getting Started](docs/general/getting_started.md) for the nuts and bolts.

More information is available in the [Guides](docs) and
[High-level behavior](README.md#high-level-behavior).

## Getting Help

If you find a bug, please report an [Issue](https://github.com/rails-api/active_model_serializers/issues/new)
and see our [contributing guide](CONTRIBUTING.md).

If you have a question, please [post to Stack Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

If you'd like to chat, we have a [community slack](http://amserializers.herokuapp.com).

Thanks!

## Documentation

If you're reading this at https://github.com/rails-api/active_model_serializers you are
reading documentation for our `master`, which may include features that have not
been released yet. Please see below for the documentation relevant to you.

- [0.10 (master) Documentation](https://github.com/rails-api/active_model_serializers/tree/master)
- [0.10.6 (latest release) Documentation](https://github.com/rails-api/active_model_serializers/tree/v0.10.6)
  - [![API Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/active_model_serializers/0.10.6)
  - [Guides](docs)
- [0.9 (0-9-stable) Documentation](https://github.com/rails-api/active_model_serializers/tree/0-9-stable)
  - [![API Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/rails-api/active_model_serializers/0-9-stable)
- [0.8 (0-8-stable) Documentation](https://github.com/rails-api/active_model_serializers/tree/0-8-stable)
  - [![API Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/rails-api/active_model_serializers/0-8-stable)


## High-level behavior

Choose an adapter from [adapters](lib/active_model_serializers/adapter):

``` ruby
ActiveModelSerializers.config.adapter = :json_api # Default: `:attributes`
```

Given a [serializable model](lib/active_model/serializer/lint.rb):

```ruby
# either
class SomeResource < ActiveRecord::Base
  # columns: title, body
end
# or
class SomeResource < ActiveModelSerializers::Model
  attributes :title, :body
end
```

And initialized as:

```ruby
resource = SomeResource.new(title: 'ActiveModelSerializers', body: 'Convention over configuration')
```

Given a serializer for the serializable model:

```ruby
class SomeSerializer < ActiveModel::Serializer
  attribute :title, key: :name
  attributes :body
end
```

The model can be serialized as:

```ruby
options = {}
serialization = ActiveModelSerializers::SerializableResource.new(resource, options)
serialization.to_json
serialization.as_json
```

SerializableResource delegates to the adapter, which it builds as:

```ruby
adapter_options = {}
adapter = ActiveModelSerializers::Adapter.create(serializer, adapter_options)
adapter.to_json
adapter.as_json
adapter.serializable_hash
```

The adapter formats the serializer's attributes and associations (a.k.a. includes):

```ruby
serializer_options = {}
serializer = SomeSerializer.new(resource, serializer_options)
serializer.attributes
serializer.associations
```

## Architecture

This section focuses on architecture the 0.10.x version of ActiveModelSerializers. If you are interested in the architecture of the 0.8 or 0.9 versions,
please refer to the [0.8 README](https://github.com/rails-api/active_model_serializers/blob/0-8-stable/README.md) or
[0.9 README](https://github.com/rails-api/active_model_serializers/blob/0-9-stable/README.md).

The original design is also available [here](https://github.com/rails-api/active_model_serializers/blob/d72b66d4c5355b0ff0a75a04895fcc4ea5b0c65e/README.textile).

### ActiveModel::Serializer

An **`ActiveModel::Serializer`** wraps a [serializable resource](https://github.com/rails/rails/blob/4-2-stable/activemodel/lib/active_model/serialization.rb)
and exposes an `attributes` method, among a few others.
It allows you to specify which attributes and associations should be represented in the serializatation of the resource.
It requires an adapter to transform its attributes into a JSON document; it cannot be serialized itself.
It may be useful to think of it as a
[presenter](http://blog.steveklabnik.com/posts/2011-09-09-better-ruby-presenters).

#### ActiveModel::CollectionSerializer

The **`ActiveModel::CollectionSerializer`** represents a collection of resources as serializers
and, if there is no serializer, primitives.

### ActiveModelSerializers::Adapter::Base

The **`ActiveModelSerializers::Adapter::Base`** describes the structure of the JSON document generated from a
serializer. For example, the `Attributes` example represents each serializer as its
unmodified attributes.  The `JsonApi` adapter represents the serializer as a [JSON
API](http://jsonapi.org/) document.

### ActiveModelSerializers::SerializableResource

The **`ActiveModelSerializers::SerializableResource`** acts to coordinate the serializer(s) and adapter
to an object that responds to `to_json`, and `as_json`.  It is used in the controller to
encapsulate the serialization resource when rendered. However, it can also be used on its own
to serialize a resource outside of a controller, as well.

### Primitive handling

Definitions: A primitive is usually a String or Array. There is no serializer
defined for them; they will be serialized when the resource is converted to JSON (`as_json` or
`to_json`).  (The below also applies for any object with no serializer.)

- ActiveModelSerializers doesn't handle primitives passed to `render json:` at all.

Internally, if no serializer can be found in the controller, the resource is not decorated by
ActiveModelSerializers.

- However, when a primitive value is an attribute or in a collection, it is not modified.

When serializing a collection and the collection serializer (CollectionSerializer) cannot
identify a serializer for a resource in its collection, it throws [`:no_serializer`](https://github.com/rails-api/active_model_serializers/issues/1191#issuecomment-142327128).
For example, when caught by `Reflection#build_association`, and the association value is set directly:

```ruby
reflection_options[:virtual_value] = association_value.try(:as_json) || association_value
```

(which is called by the adapter as `serializer.associations(*)`.)

### How options are parsed

High-level overview:

- For a **collection**
  - `:serializer` specifies the collection serializer and
  - `:each_serializer` specifies the serializer for each resource in the collection.
- For a **single resource**, the `:serializer` option is the resource serializer.
- Options are partitioned in serializer options and adapter options.  Keys for adapter options are specified by
    [`ADAPTER_OPTION_KEYS`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/serializable_resource.rb#L5).
    The remaining options are serializer options.

Details:

1. **ActionController::Serialization**
  1. `serializable_resource = ActiveModelSerializers::SerializableResource.new(resource, options)`
    1. `options` are partitioned into `adapter_opts` and everything else (`serializer_opts`).
      The `adapter_opts` keys are defined in [`ActiveModelSerializers::SerializableResource::ADAPTER_OPTION_KEYS`](lib/active_model_serializers/serializable_resource.rb#L5).
1. **ActiveModelSerializers::SerializableResource**
  1. `if serializable_resource.serializer?` (there is a serializer for the resource, and an adapter is used.)
    - Where `serializer?` is `use_adapter? && !!(serializer)`
      - Where `use_adapter?`: 'True when no explicit adapter given, or explicit value is truthy (non-nil);
        False when explicit adapter is falsy (nil or false)'
      - Where `serializer`:
        1. from explicit `:serializer` option, else
        2. implicitly from resource `ActiveModel::Serializer.serializer_for(resource)`
  1. A side-effect of checking `serializer` is:
     - The `:serializer` option is removed from the serializer_opts hash
     - If the `:each_serializer` option is present, it is removed from the serializer_opts hash and set as the `:serializer` option
  1. The serializer and adapter are created as
    1. `serializer_instance = serializer.new(resource, serializer_opts)`
    2. `adapter_instance = ActiveModel::Serializer::Adapter.create(serializer_instance, adapter_opts)`
1. **ActiveModel::Serializer::CollectionSerializer#new**
  1. If the `serializer_instance` was a `CollectionSerializer` and the `:serializer` serializer_opts
    is present, then [that serializer is passed into each resource](https://github.com/rails-api/active_model_serializers/blob/a54d237e2828fe6bab1ea5dfe6360d4ecc8214cd/lib/active_model/serializer/array_serializer.rb#L14-L16).
1. **ActiveModel::Serializer#attributes** is used by the adapter to get the attributes for
  resource as defined by the serializer.

(In Rails, the `options` are also passed to the `as_json(options)` or `to_json(options)`
methods on the resource serialization by the Rails JSON renderer.  They are, therefore, important
to know about, but not part of ActiveModelSerializers.)

### What does a 'serializable resource' look like?

- An `ActiveRecord::Base` object.
- Any Ruby object that passes the
  [Lint](http://www.rubydoc.info/github/rails-api/active_model_serializers/ActiveModel/Serializer/Lint/Tests)
  [code](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model/serializer/lint.rb).

ActiveModelSerializers provides a
[`ActiveModelSerializers::Model`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/model.rb),
which is a simple serializable PORO (Plain-Old Ruby Object).

`ActiveModelSerializers::Model` may be used either as a reference implementation, or in production code.

```ruby
class MyModel < ActiveModelSerializers::Model
  attributes :id, :name, :level
end
```

The default serializer for `MyModel` would be `MyModelSerializer` whether MyModel is an
ActiveRecord::Base object or not.

Outside of the controller the rules are **exactly** the same as for records. For example:

```ruby
render json: MyModel.new(level: 'awesome'), adapter: :json
```

would be serialized the same as

```ruby
ActiveModelSerializers::SerializableResource.new(MyModel.new(level: 'awesome'), adapter: :json).as_json
```

## Semantic Versioning

This project adheres to [semver](http://semver.org/)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
