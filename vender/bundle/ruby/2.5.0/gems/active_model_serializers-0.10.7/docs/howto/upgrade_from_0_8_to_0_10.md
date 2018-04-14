[Back to Guides](../README.md)

# How to migrate from `0.8` to `0.10` safely

## Disclaimer
### Proceed at your own risk
This document attempts to outline steps to upgrade your app based on the collective experience of
developers who have done this already. It may not cover all edge cases and situations that may cause issues,
so please proceed with a certain level of caution.

## Overview
This document outlines the steps needed to migrate from `0.8` to `0.10`. The method described
below has been created via the collective knowledge of contributions of those who have done
the migration successfully. The method has been tested specifically for migrating from `0.8.3`
to `0.10.2`.

The high level approach is to upgrade to `0.10` and change all serializers to use
a backwards-compatible `ActiveModel::V08::Serializer`or `ActiveModel::V08::CollectionSerializer`
and a `ActiveModelSerializers::Adapter::V08Adapter`. After a few more manual changes, you should have the same
functionality as you had with `AMS 0.8`. Then, you can continue to develop in your app by creating
new serializers that don't use these backwards compatible versions and slowly migrate
existing serializers to the `0.10` versions as needed.

### `0.10` breaking changes
- Passing a serializer to `render json:` is no longer supported

```ruby
render json: CustomerSerializer.new(customer) # rendered in 0.8, errors in 0.10
```

- Passing a nil resource to serializer now fails

```ruby
CustomerSerializer.new(nil) # returned nil in 0.8, throws error in 0.10
```

- Attribute methods are no longer defined on the serializer, and must be explicitly
  accessed through `object`

```ruby
class MySerializer
  attributes :foo, :bar

  def foo
    bar + 1 # bar does not work, needs to be object.bar in 0.10
  end
end
```

 - `root` option to collection serializer behaves differently

```ruby
# in 0.8
ActiveModel::ArraySerializer.new(resources, root: "resources")
# resulted in { "resources": <serialized_resources> }, does not work in 0.10
```

- No default serializer when serializer doesn't exist
- `@options` changed to `instance_options`
- Nested relationships are no longer walked by default. Use the `:include` option at **controller `render`** level to specify what relationships to walk. E.g. `render json: @post, include: {comments: :author}` if you want the `author` relationship walked, otherwise the json would only include the post with comments. See: https://github.com/rails-api/active_model_serializers/pull/1127
- To emulate `0.8`'s walking of arbitrarily deep relationships use: `include: '**'`. E.g. `render json: @post, include: '**'`

## Steps to migrate

### 1. Upgrade the `active_model_serializer` gem in you `Gemfile`
Change to `gem 'active_model_serializers', '~> 0.10'` and run `bundle install`

### 2. Add `ActiveModel::V08::Serializer`

```ruby
module ActiveModel
  module V08
    class Serializer < ActiveModel::Serializer
      include Rails.application.routes.url_helpers

      # AMS 0.8 would delegate method calls from within the serializer to the
      # object.
      def method_missing(*args)
        method = args.first
        read_attribute_for_serialization(method)
      end

      alias_method :options, :instance_options

      # Since attributes could be read from the `object` via `method_missing`,
      # the `try` method did not behave as before. This patches `try` with the
      # original implementation plus the addition of
      # ` || object.respond_to?(a.first, true)` to check if the object responded to
      # the given method.
      def try(*a, &b)
        if a.empty? || respond_to?(a.first, true) || object.respond_to?(a.first, true)
          try!(*a, &b)
        end
      end

      # AMS 0.8 would return nil if the serializer was initialized with a nil
      # resource.
      def serializable_hash(adapter_options = nil,
                            options = {},
                            adapter_instance =
                              self.class.serialization_adapter_instance)
        object.nil? ? nil : super
      end
    end
  end
end

```
Add this class to your app however you see fit. This is the class that your existing serializers
that inherit from `ActiveModel::Serializer` should inherit from.

### 3. Add `ActiveModel::V08::CollectionSerializer`
```ruby
module ActiveModel
  module V08
    class CollectionSerializer < ActiveModel::Serializer::CollectionSerializer
      # In AMS 0.8, passing an ArraySerializer instance with a `root` option
      # properly nested the serialized resources within the given root.
      # Ex.
      #
      # class MyController < ActionController::Base
      #   def index
      #     render json: ActiveModel::Serializer::ArraySerializer
      #       .new(resources, root: "resources")
      #   end
      # end
      #
      # Produced
      #
      # {
      #   "resources": [
      #     <serialized_resource>,
      #     ...
      #   ]
      # }
      def as_json(options = {})
        if root
          {
            root => super
          }
        else
          super
        end
      end

      # AMS 0.8 used `DefaultSerializer` if it couldn't find a serializer for
      # the given resource. When not using an adapter, this is not true in
      # `0.10`
      def serializer_from_resource(resource, serializer_context_class, options)
        serializer_class =
          options.fetch(:serializer) { serializer_context_class.serializer_for(resource) }

        if serializer_class.nil? # rubocop:disable Style/GuardClause
          DefaultSerializer.new(resource, options)
        else
          serializer_class.new(resource, options.except(:serializer))
        end
      end

      class DefaultSerializer
        attr_reader :object, :options

        def initialize(object, options={})
          @object, @options = object, options
        end

        def serializable_hash
          @object.as_json(@options)
        end
      end
    end
  end
end
```
Add this class to your app however you see fit. This is the class that existing uses of
`ActiveModel::ArraySerializer` should be changed to use.

### 4. Add `ActiveModelSerializers::Adapter::V08Adapter`
```ruby
module ActiveModelSerializers
  module Adapter
    class V08Adapter < ActiveModelSerializers::Adapter::Base
      def serializable_hash(options = nil)
        options ||= {}

        if serializer.respond_to?(:each)
          if serializer.root
            delegate_to_json_adapter(options)
          else
            serializable_hash_for_collection(options)
          end
        else
          serializable_hash_for_single_resource(options)
        end
      end

      def serializable_hash_for_collection(options)
        serializer.map do |s|
          V08Adapter.new(s, instance_options)
            .serializable_hash(options)
        end
      end

      def serializable_hash_for_single_resource(options)
        if serializer.object.is_a?(ActiveModel::Serializer)
          # It is recommended that you add some logging here to indicate
          # places that should get converted to eventually allow for this
          # adapter to get removed.
          @serializer = serializer.object
        end

        if serializer.root
          delegate_to_json_adapter(options)
        else
          options = serialization_options(options)
          serializer.serializable_hash(instance_options, options, self)
        end
      end

      def delegate_to_json_adapter(options)
        ActiveModelSerializers::Adapter::Json
          .new(serializer, instance_options)
          .serializable_hash(options)
      end
    end
  end
end
```
Add this class to your app however you see fit.

Add
```ruby
ActiveModelSerializers.config.adapter =
  ActiveModelSerializers::Adapter::V08Adapter
```
to `config/active_model_serializer.rb` to configure AMS to use this
class as the default adapter.

### 5. Change inheritors of `ActiveModel::Serializer` to inherit from `ActiveModel::V08::Serializer`
Simple find/replace

### 6. Remove `private` keyword from serializers
Simple find/replace. This is required to allow the `ActiveModel::V08::Serializer`
to have proper access to the methods defined in the serializer.

You may be able to change the `private` to `protected`, but this is hasn't been tested yet.

### 7. Remove references to `ActiveRecord::Base#active_model_serializer`
This method is no longer supported in `0.10`.

`0.10` does a good job of discovering serializers for `ActiveRecord` objects.

### 8. Rename `ActiveModel::ArraySerializer` to `ActiveModel::V08::CollectionSerializer`
Find/replace uses of `ActiveModel::ArraySerializer` with `ActiveModel::V08::CollectionSerializer`.

Also, be sure to change the `each_serializer` keyword to `serializer` when calling making the replacement.

### 9. Replace uses of `@options` to `instance_options` in serializers
Simple find/replace

## Conclusion
After you've done the steps above, you should test your app to ensure that everything is still working properly.

If you run into issues, please contribute back to this document so others can benefit from your knowledge.

