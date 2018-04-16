[Back to Guides](../README.md)

# How to serialize a Plain-Old Ruby Object (PORO)

When you are first getting started with ActiveModelSerializers, it may seem only `ActiveRecord::Base` objects can be serializable,
but pretty much any object can be serializable with ActiveModelSerializers.
Here is an example of a PORO that is serializable in most situations:

```ruby
# my_model.rb
class MyModel
  alias :read_attribute_for_serialization :send
  attr_accessor :id, :name, :level

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @level = attributes[:level]
  end

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end
end
```

The [ActiveModel::Serializer::Lint::Tests](../../lib/active_model/serializer/lint.rb)
define and validate which methods ActiveModelSerializers expects to be implemented.

An implementation of the complete spec is included either for use or as reference:
[`ActiveModelSerializers::Model`](../../lib/active_model_serializers/model.rb).
You can use in production code that will make your PORO a lot cleaner.

The above code now becomes:

```ruby
# my_model.rb
class MyModel < ActiveModelSerializers::Model
  attributes :id, :name, :level
end
```

The default serializer would be `MyModelSerializer`.

*IMPORTANT*: There is a surprising behavior (bug) in the current implementation of ActiveModelSerializers::Model that
prevents an accessor from modifying attributes on the instance.  The fix for this bug
is a breaking change, so we have made an opt-in configuration.

New applications should set:

```ruby
ActiveModelSerializers::Model.derive_attributes_from_names_and_fix_accessors
```

Existing applications can use the fix *and* avoid breaking changes
by making a superclass for new models. For example:

```ruby
class SerializablePoro < ActiveModelSerializers::Model
  derive_attributes_from_names_and_fix_accessors
end
```

So that `MyModel` above would inherit from `SerializablePoro`.

`derive_attributes_from_names_and_fix_accessors` prepends the `DeriveAttributesFromNamesAndFixAccessors`
module and does the following:

- `id` will *always* be in the attributes. (This is until we separate out the caching requirement for POROs.)
- Overwrites the `attributes` method to that it only returns declared attributes.
 `attributes` will now be a frozen hash with indifferent access.

For more information, see [README: What does a 'serializable resource' look like?](../../README.md#what-does-a-serializable-resource-look-like).
