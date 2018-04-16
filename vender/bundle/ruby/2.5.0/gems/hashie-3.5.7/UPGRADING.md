Upgrading Hashie
================

### Upgrading to 3.5.2

#### Disable logging in Mash subclasses

If you subclass `Hashie::Mash`, you can now disable the logging we do about
overriding existing methods with keys. This looks like:

```ruby
class MyMash < Hashie::Mash
  disable_warnings
end
```

### Upgrading to 3.4.7

#### Procs as default values for Dash

```ruby
class MyHash < Hashie::Dash
  property :time, default: -> { Time.now }
end
```

In versions < 3.4.7 `Time.now` will be evaluated when `time` property is accessed directly first time.
In version >= 3.4.7 `Time.now` is evaluated in time of object initialization.
### Upgrading to 3.4.4

#### Mash subclasses and reverse_merge

```ruby
class MyMash < Hashie::Mash
end
```

In versions >= 3.4.4 `MyMash#reverse_merge` returns an instance of `MyMash` but in previous versions it was a `Hashie::Mash` instance.

### Upgrading to 3.2.2

#### Testing if key defined

In versions <= 3.2.1 Hash object being questioned doesn't return a boolean value as it's mentioned in README.md

```ruby
class MyHash < Hash
  include Hashie::Extensions::MethodAccess
end

h = MyHash.new
h.abc = 'def'
h.abc  # => 'def'
h.abc? # => 'def'
```

In versions >= 3.2.2 it returns a boolean value

```ruby
h.abc? # => true
h.abb? # => false
```

### Upgrading to 3.2.1

#### Possible coercion changes

The improvements made to coercions in version 3.2.1 [issue #200](https://github.com/intridea/hashie/pull/200) do not break the documented API, but are significant enough that changes may effect undocumented side-effects. Applications that depended on those side-effects will need to be updated.

**Change**: Type coercion no longer creates new objects if the input matches the target type. Previously coerced properties always resulted in the creation of a new object, even when it wasn't necessary. This had the effect of a `dup` or `clone` on coerced properties but not uncoerced ones.

If necessary, `dup` or `clone` your own objects. Do not assume Hashie will do it for you.

**Change**: Failed coercion attempts now raise Hashie::CoercionError.

Hashie now raises a Hashie::CoercionError that details on the property that could not be coerced, the source and target type of the coercion, and the internal error. Previously only the internal error was raised.

Applications that were attempting to rescuing the internal errors should be updated to rescue Hashie::CoercionError instead.

### Upgrading to 3.0

#### Compatibility with Rails 4 Strong Parameters

Version 2.1 introduced support to prevent default Rails 4 mass-assignment protection behavior. This was [issue #89](https://github.com/intridea/hashie/issues/89), resolved in [#104](https://github.com/intridea/hashie/pull/104). In version 2.2 this behavior has been removed in [#147](https://github.com/intridea/hashie/pull/147) in favor of a mixin and finally extracted into a separate gem in Hashie 3.0.

To enable 2.1 compatible behavior with Rails 4, use the [hashie_rails](http://rubygems.org/gems/hashie_rails) gem.

```
gem 'hashie_rails'
```

See [#154](https://github.com/intridea/hashie/pull/154) and [Mash and Rails 4 Strong Parameters](README.md#mash-and-rails-4-strong-parameters) for more details.

#### Key Conversions in Hashie::Dash and Hashie::Trash

Version 2.1 and older of Hashie::Dash and Hashie::Trash converted keys to strings by default. This is no longer the case in 2.2.

Consider the following code.

```ruby
class Person < Hashie::Dash
  property :name
end

p = Person.new(name: 'dB.')
```

Version 2.1 behaves as follows.

```ruby
p.name # => 'dB.'
p[:name] # => 'dB.'
p['name'] # => 'dB.'

# not what I put in
p.inspect # => { 'name' => 'dB.' }
p.to_hash # => { 'name' => 'dB.' }
```

It was not possible to achieve the behavior of preserving keys, as described in [issue #151](https://github.com/intridea/hashie/issues/151).

Version 2.2 does not perform this conversion by default.

```ruby
p.name # => 'dB.'
p[:name] # => 'dB.'
# p['name'] # => NoMethodError

p.inspect # => { :name => 'dB.' }
p.to_hash # => { :name => 'dB.' }
```

To enable behavior compatible with older versions, use `Hashie::Extensions::Dash::IndifferentAccess`.

```ruby
class Person < Hashie::Dash
  include Hashie::Extensions::Dash::IndifferentAccess
  property :name
end
```

#### Key Conversions in Hashie::Hash#to_hash

Version 2.1 or older of Hash#to_hash converted keys to strings automatically.

```ruby
instance = Hashie::Hash[first: 'First', 'last' => 'Last']
instance.to_hash # => { "first" => 'First', "last" => 'Last' }
```

It was possible to symbolize keys by passing `:symbolize_keys`, however it was not possible to retrieve the hash with initial key values.

```ruby
instance.to_hash(symbolize_keys: true) # => { :first => 'First', :last => 'Last' }
instance.to_hash(stringify_keys: true) # => { "first" => 'First', "last" => 'Last' }
```

Version 2.2 no longer converts keys by default.

```ruby
instance = Hashie::Hash[first: 'First', 'last' => 'Last']
instance.to_hash # => { :first => 'First', "last" => 'Last' }
```

The behavior with `symbolize_keys` and `stringify_keys` is unchanged.

See [#152](https://github.com/intridea/hashie/pull/152) for more information.


