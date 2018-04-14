# Hashie

[![Join the chat at https://gitter.im/intridea/hashie](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/intridea/hashie?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Gem Version](http://img.shields.io/gem/v/hashie.svg)](http://badge.fury.io/rb/hashie)
[![Build Status](http://img.shields.io/travis/intridea/hashie.svg)](https://travis-ci.org/intridea/hashie)
[![Dependency Status](https://gemnasium.com/intridea/hashie.svg)](https://gemnasium.com/intridea/hashie)
[![Code Climate](https://codeclimate.com/github/intridea/hashie.svg)](https://codeclimate.com/github/intridea/hashie)
[![Coverage Status](https://codeclimate.com/github/intridea/hashie/badges/coverage.svg)](https://codeclimate.com/github/intridea/hashie)

Hashie is a growing collection of tools that extend Hashes and make them more useful.

## Installation

Hashie is available as a RubyGem:

```bash
$ gem install hashie
```

## Upgrading

You're reading the documentation for the stable release of Hashie, 3.5.7. Please read [UPGRADING](UPGRADING.md) when upgrading from a previous version.

## Hash Extensions

The library is broken up into a number of atomically includable Hash extension modules as described below. This provides maximum flexibility for users to mix and match functionality while maintaining feature parity with earlier versions of Hashie.

Any of the extensions listed below can be mixed into a class by `include`-ing `Hashie::Extensions::ExtensionName`.

## Logging

Hashie has a built-in logger that you can override. By default, it logs to `STDOUT` but can be replaced by any `Logger` class. The logger is accessible on the Hashie module, as shown below:

```ruby
# Set the logger to the Rails logger
Hashie.logger = Rails.logger
```

### Coercion

Coercions allow you to set up "coercion rules" based either on the key or the value type to massage data as it's being inserted into the Hash. Key coercions might be used, for example, in lightweight data modeling applications such as an API client:

```ruby
class Tweet < Hash
  include Hashie::Extensions::Coercion
  include Hashie::Extensions::MergeInitializer
  coerce_key :user, User
end

user_hash = { name: "Bob" }
Tweet.new(user: user_hash)
# => automatically calls User.coerce(user_hash) or
#    User.new(user_hash) if that isn't present.
```

Value coercions, on the other hand, will coerce values based on the type of the value being inserted. This is useful if you are trying to build a Hash-like class that is self-propagating.

```ruby
class SpecialHash < Hash
  include Hashie::Extensions::Coercion
  coerce_value Hash, SpecialHash

  def initialize(hash = {})
    super
    hash.each_pair do |k,v|
      self[k] = v
    end
  end
end
```

### Coercing Collections

```ruby
class Tweet < Hash
  include Hashie::Extensions::Coercion
  coerce_key :mentions, Array[User]
  coerce_key :friends, Set[User]
end

user_hash = { name: "Bob" }
mentions_hash= [user_hash, user_hash]
friends_hash = [user_hash]
tweet = Tweet.new(mentions: mentions_hash, friends: friends_hash)
# => automatically calls User.coerce(user_hash) or
#    User.new(user_hash) if that isn't present on each element of the array

tweet.mentions.map(&:class) # => [User, User]
tweet.friends.class # => Set
```

### Coercing Hashes

```ruby
class Relation
  def initialize(string)
    @relation = string
  end
end

class Tweet < Hash
  include Hashie::Extensions::Coercion
  coerce_key :relations, Hash[User => Relation]
end

user_hash = { name: "Bob" }
relations_hash= { user_hash => "father", user_hash => "friend" }
tweet = Tweet.new(relations: relations_hash)
tweet.relations.map { |k,v| [k.class, v.class] } # => [[User, Relation], [User, Relation]]
tweet.relations.class # => Hash

# => automatically calls User.coerce(user_hash) on each key
#    and Relation.new on each value since Relation doesn't define the `coerce` class method
```

### Coercing Core Types

Hashie handles coercion to the following by using standard conversion methods:

| type     | method   |
|----------|----------|
| Integer  | `#to_i`  |
| Float    | `#to_f`  |
| Complex  | `#to_c`  |
| Rational | `#to_r`  |
| String   | `#to_s`  |
| Symbol   | `#to_sym`|

**Note**: The standard Ruby conversion methods are less strict than you may assume. For example, `:foo.to_i` raises an error but `"foo".to_i` returns 0.

You can also use coerce from the following supertypes with `coerce_value`:
- Integer
- Numeric

Hashie does not have built-in support for coercion boolean values, since Ruby does not have a built-in boolean type or standard method for to a boolean. You can coerce to booleans using a custom proc.

### Coercion Proc

You can use a custom coercion proc on either `#coerce_key` or `#coerce_value`. This is useful for coercing to booleans or other simple types without creating a new class and `coerce` method. For example:

```ruby
class Tweet < Hash
  include Hashie::Extensions::Coercion
  coerce_key :retweeted, ->(v) do
    case v
    when String
      !!(v =~ /\A(true|t|yes|y|1)\z/i)
    when Numeric
      !v.to_i.zero?
    else
      v == true
    end
  end
end
```

#### A note on circular coercion

Since `coerce_key` is a class-level method, you cannot have circular coercion without the use of a proc. For example:

```ruby
class CategoryHash < Hash
  include Hashie::Extensions::Coercion
  include Hashie::Extensions::MergeInitializer

  coerce_key :products, Array[ProductHash]
end

class ProductHash < Hash
  include Hashie::Extensions::Coercion
  include Hashie::Extensions::MergeInitializer

  coerce_key :categories, Array[CategoriesHash]
end
```

This will fail with a `NameError` for `CategoryHash::ProductHash` because `ProductHash` is not defined at the point that `coerce_key` is happening for `CategoryHash`.

To work around this, you can use a coercion proc. For example, you could do:

```ruby
class CategoryHash < Hash
  # ...
  coerce_key :products, ->(value) do
    return value.map { |v| ProductHash.new(v) } if value.respond_to?(:map)

    ProductHash.new(value)
  end
end
```

### KeyConversion

The KeyConversion extension gives you the convenience methods of `symbolize_keys` and `stringify_keys` along with their bang counterparts. You can also include just stringify or just symbolize with `Hashie::Extensions::StringifyKeys` or `Hashie::Extensions::SymbolizeKeys`.

Hashie also has a utility method for converting keys on a Hash without a mixin:

```ruby
Hashie.symbolize_keys! hash # => Symbolizes keys of hash.
Hashie.symbolize_keys hash # => Returns a copy of hash with keys symbolized.
Hashie.stringify_keys! hash # => Stringifies keys of hash.
Hashie.stringify_keys hash # => Returns a copy of hash with keys stringified.
```

### MergeInitializer

The MergeInitializer extension simply makes it possible to initialize a Hash subclass with another Hash, giving you a quick short-hand.

### MethodAccess

The MethodAccess extension allows you to quickly build method-based reading, writing, and querying into your Hash descendant. It can also be included as individual modules, i.e. `Hashie::Extensions::MethodReader`, `Hashie::Extensions::MethodWriter` and `Hashie::Extensions::MethodQuery`.

```ruby
class MyHash < Hash
  include Hashie::Extensions::MethodAccess
end

h = MyHash.new
h.abc = 'def'
h.abc  # => 'def'
h.abc? # => true
```

### MethodAccessWithOverride

The MethodAccessWithOverride extension is like the MethodAccess extension, except that it allows you to override Hash methods. It aliases any overridden method with two leading underscores. To include only this overriding functionality, you can include the single module `Hashie::Extensions::MethodOverridingWriter`.

```ruby
class MyHash < Hash
  include Hashie::Extensions::MethodAccess
end

class MyOverridingHash < Hash
  include Hashie::Extensions::MethodAccessWithOverride
end

non_overriding = MyHash.new
non_overriding.zip = 'a-dee-doo-dah'
non_overriding.zip #=> [[['zip', 'a-dee-doo-dah']]]

overriding = MyOverridingHash.new
overriding.zip = 'a-dee-doo-dah'
overriding.zip   #=> 'a-dee-doo-dah'
overriding.__zip #=> [[['zip', 'a-dee-doo-dah']]]
```

### IndifferentAccess

This extension can be mixed in to your Hash subclass to allow you to use Strings or Symbols interchangeably as keys; similar to the `params` hash in Rails.

In addition, IndifferentAccess will also inject itself into sub-hashes so they behave the same.

Example:

```ruby
class MyHash < Hash
  include Hashie::Extensions::MergeInitializer
  include Hashie::Extensions::IndifferentAccess
end

myhash = MyHash.new(:cat => 'meow', 'dog' => 'woof')
myhash['cat'] # => "meow"
myhash[:cat]  # => "meow"
myhash[:dog]  # => "woof"
myhash['dog'] # => "woof"

# Auto-Injecting into sub-hashes.
myhash['fishes'] = {}
myhash['fishes'].class # => Hash
myhash['fishes'][:food] = 'flakes'
myhash['fishes']['food'] # => "flakes"
```

### IgnoreUndeclared

This extension can be mixed in to silently ignore undeclared properties on initialization instead of raising an error. This is useful when using a Trash to capture a subset of a larger hash.

```ruby
class Person < Trash
  include Hashie::Extensions::IgnoreUndeclared
  property :first_name
  property :last_name
end

user_data = {
  first_name: 'Freddy',
  last_name: 'Nostrils',
  email: 'freddy@example.com'
}

p = Person.new(user_data) # 'email' is silently ignored

p.first_name # => 'Freddy'
p.last_name  # => 'Nostrils'
p.email      # => NoMethodError
```

### DeepMerge

This extension allow you to easily include a recursive merging
system to any Hash descendant:

```ruby
class MyHash < Hash
  include Hashie::Extensions::DeepMerge
end

h1 = MyHash[{ x: { y: [4,5,6] }, z: [7,8,9] }]
h2 = MyHash[{ x: { y: [7,8,9] }, z: "xyz" }]

h1.deep_merge(h2) # => { x: { y: [7, 8, 9] }, z: "xyz" }
h2.deep_merge(h1) # => { x: { y: [4, 5, 6] }, z: [7, 8, 9] }
```

Like with Hash#merge in the standard library, a block can be provided to merge values:

```ruby
class MyHash < Hash
  include Hashie::Extensions::DeepMerge
end

h1 = MyHash[{ a: 100, b: 200, c: { c1: 100 } }]
h2 = MyHash[{ b: 250, c: { c1: 200 } }]

h1.deep_merge(h2) { |key, this_val, other_val| this_val + other_val }
# => { a: 100, b: 450, c: { c1: 300 } }
```


### DeepFetch

This extension can be mixed in to provide for safe and concise retrieval of deeply nested hash values. In the event that the requested key does not exist a block can be provided and its value will be returned.

Though this is a hash extension, it conveniently allows for arrays to be present in the nested structure. This feature makes the extension particularly useful for working with JSON API responses.

```ruby
user = {
  name: { first: 'Bob', last: 'Boberts' },
  groups: [
    { name: 'Rubyists' },
    { name: 'Open source enthusiasts' }
  ]
}

user.extend Hashie::Extensions::DeepFetch

user.deep_fetch :name, :first # => 'Bob'
user.deep_fetch :name, :middle # => 'KeyError: Could not fetch middle'

# using a default block
user.deep_fetch(:name, :middle) { |key| 'default' }  # =>  'default'

# a nested array
user.deep_fetch :groups, 1, :name # => 'Open source enthusiasts'
```

### DeepFind

This extension can be mixed in to provide for concise searching for keys within a deeply nested hash.

It can also search through any Enumerable contained within the hash for objects with the specified key.

Note: The searches are depth-first, so it is not guaranteed that a shallowly nested value will be found before a deeply nested value.

```ruby
user = {
  name: { first: 'Bob', last: 'Boberts' },
  groups: [
    { name: 'Rubyists' },
    { name: 'Open source enthusiasts' }
  ]
}

user.extend Hashie::Extensions::DeepFind

user.deep_find(:name)   #=> { first: 'Bob', last: 'Boberts' }
user.deep_detect(:name) #=> { first: 'Bob', last: 'Boberts' }

user.deep_find_all(:name) #=> [{ first: 'Bob', last: 'Boberts' }, 'Rubyists', 'Open source enthusiasts']
user.deep_select(:name)   #=> [{ first: 'Bob', last: 'Boberts' }, 'Rubyists', 'Open source enthusiasts']
```

### DeepLocate

This extension can be mixed in to provide a depth first search based search for enumerables matching a given comparator callable.

It returns all enumerables which contain at least one element, for which the given comparator returns ```true```.

Because the container objects are returned, the result elements can be modified in place. This way, one can perform modifications on deeply nested hashes without the need to know the exact paths.

```ruby

books = [
  {
    title: "Ruby for beginners",
    pages: 120
  },
  {
    title: "CSS for intermediates",
    pages: 80
  },
  {
    title: "Collection of ruby books",
    books: [
      {
        title: "Ruby for the rest of us",
        pages: 576
      }
    ]
  }
]

books.extend(Hashie::Extensions::DeepLocate)

# for ruby 1.9 leave *no* space between the lambda rocket and the braces
# http://ruby-journal.com/becareful-with-space-in-lambda-hash-rocket-syntax-between-ruby-1-dot-9-and-2-dot-0/

books.deep_locate -> (key, value, object) { key == :title && value.include?("Ruby") }
# => [{:title=>"Ruby for beginners", :pages=>120}, {:title=>"Ruby for the rest of us", :pages=>576}]

books.deep_locate -> (key, value, object) { key == :pages && value <= 120 }
# => [{:title=>"Ruby for beginners", :pages=>120}, {:title=>"CSS for intermediates", :pages=>80}]
```

## StrictKeyAccess

This extension can be mixed in to allow a Hash to raise an error when attempting to extract a value using a non-existent key.

### Example:

```ruby
class StrictKeyAccessHash < Hash
  include Hashie::Extensions::StrictKeyAccess
end

>> hash = StrictKeyAccessHash[foo: "bar"]
=> {:foo=>"bar"}
>> hash[:foo]
=> "bar"
>> hash[:cow]
  KeyError: key not found: :cow
```

## Mash

Mash is an extended Hash that gives simple pseudo-object functionality that can be built from hashes and easily extended. It is intended to give the user easier access to the objects within the Mash through a property-like syntax, while still retaining all Hash functionality.

### Example:

```ruby
mash = Hashie::Mash.new
mash.name? # => false
mash.name # => nil
mash.name = "My Mash"
mash.name # => "My Mash"
mash.name? # => true
mash.inspect # => <Hashie::Mash name="My Mash">

mash = Hashie::Mash.new
# use bang methods for multi-level assignment
mash.author!.name = "Michael Bleigh"
mash.author # => <Hashie::Mash name="Michael Bleigh">

mash = Hashie::Mash.new
# use under-bang methods for multi-level testing
mash.author_.name? # => false
mash.inspect # => <Hashie::Mash>
```

**Note:** The `?` method will return false if a key has been set to false or nil. In order to check if a key has been set at all, use the `mash.key?('some_key')` method instead.

Please note that a Mash will not override methods through the use of the property-like syntax. This can lead to confusion if you expect to be able to access a Mash value through the property-like syntax for a key that conflicts with a method name. However, it protects users of your library from the unexpected behavior of those methods being overridden behind the scenes.

### Example:

```ruby
mash = Hashie::Mash.new
mash.name = "My Mash"
mash.zip = "Method Override?"
mash.zip # => [[["name", "My Mash"]], [["zip", "Method Override?"]]]
```

Mash allows you also to transform any files into a Mash objects.

### Example:

```yml
#/etc/config/settings/twitter.yml
development:
  api_key: 'api_key'
production:
  api_key: <%= ENV['API_KEY'] %> #let's say that ENV['API_KEY'] is set to 'abcd'
```

```ruby
mash = Mash.load('settings/twitter.yml')
mash.development.api_key # => 'localhost'
mash.development.api_key = "foo" # => <# RuntimeError can't modify frozen ...>
mash.development.api_key? # => true
```

You can also load with a `Pathname` object:

```ruby
mash = Mash.load(Pathname 'settings/twitter.yml')
mash.development.api_key # => 'localhost'
```

You can access a Mash from another class:

```ruby
mash = Mash.load('settings/twitter.yml')[ENV['RACK_ENV']]
Twitter.extend mash.to_module # NOTE: if you want another name than settings, call: to_module('my_settings')
Twitter.settings.api_key # => 'abcd'
```

You can use another parser (by default: YamlErbParser):

```
#/etc/data/user.csv
id | name          | lastname
---|------------- | -------------
1  |John          | Doe
2  |Laurent       | Garnier
```

```ruby
mash = Mash.load('data/user.csv', parser: MyCustomCsvParser)
# => { 1 => { name: 'John', lastname: 'Doe'}, 2 => { name: 'Laurent', lastname: 'Garnier' } }
mash[1] #=> { name: 'John', lastname: 'Doe' }
```

Since Mash gives you the ability to set arbitrary keys that then act as methods, Hashie logs when there is a conflict between a key and a pre-existing method. You can set the logger that this logs message to via the global Hashie logger:

```ruby
Hashie.logger = Rails.logger
```

You can also disable the logging in subclasses of Mash:

```ruby
class Response < Hashie::Mash
  disable_warnings
end
```

### Mash Extension: KeepOriginalKeys

This extension can be mixed into a Mash to keep the form of any keys passed directly into the Mash. By default, Mash converts keys to strings to give indifferent access. This extension still allows indifferent access, but keeps the form of the keys to eliminate confusion when you're not expecting the keys to change.

```ruby
class KeepingMash < ::Hashie::Mash
  include Hashie::Extensions::Mash::KeepOriginalKeys
end

mash = KeepingMash.new(:symbol_key => :symbol, 'string_key' => 'string')
mash.to_hash == { :symbol_key => :symbol, 'string_key' => 'string' }  #=> true
mash.symbol_key  #=> :symbol
mash[:symbol_key]  #=> :symbol
mash['symbol_key']  #=> :symbol
mash.string_key  #=> 'string'
mash['string_key']  #=> 'string'
mash[:string_key]  #=> 'string'
```

### Mash Extension: SafeAssignment

This extension can be mixed into a Mash to guard the attempted overwriting of methods by property setters. When mixed in, the Mash will raise an `ArgumentError` if you attempt to write a property with the same name as an existing method.

#### Example:

```ruby
class SafeMash < ::Hashie::Mash
  include Hashie::Extensions::Mash::SafeAssignment
end

safe_mash = SafeMash.new
safe_mash.zip   = 'Test' # => ArgumentError
safe_mash[:zip] = 'test' # => still ArgumentError
```

### Mash Extension:: SymbolizeKeys

This extension can be mixed into a Mash to change the default behavior of converting keys to strings. After mixing this extension into a Mash, the Mash will convert all keys to symbols.

```ruby
class SymbolizedMash < ::Hashie::Mash
  include Hashie::Extensions::Mash::SymbolizeKeys
end

symbol_mash = SymbolizedMash.new
symbol_mash['test'] = 'value'
symbol_mash.test  #=> 'value'
symbol_mash.to_h  #=> {test: 'value'}
```

There is a major benefit and coupled with a major trade-off to this decision (at least on older Rubies). As a benefit, by using symbols as keys, you will be able to use the implicit conversion of a Mash via the `#to_hash` method to destructure (or splat) the contents of a Mash out to a block. This can be handy for doing iterations through the Mash's keys and values, as follows:

```ruby
symbol_mash = SymbolizedMash.new(id: 123, name: 'Rey')
symbol_mash.each do |key, value|
  # key is :id, then :name
  # value is 123, then 'Rey'
end
```

However, on Rubies less than 2.0, this means that every key you send to the Mash will generate a symbol. Since symbols are not garbage-collected on older versions of Ruby, this can cause a slow memory leak when using a symbolized Mash with data generated from user input.

## Dash

Dash is an extended Hash that has a discrete set of defined properties and only those properties may be set on the hash. Additionally, you can set defaults for each property. You can also flag a property as required. Required properties will raise an exception if unset. Another option is message for required properties, which allow you to add custom messages for required property.

You can also conditionally require certain properties by passing a Proc or Symbol. If a Proc is provided, it will be run in the context of the Dash instance. If a Symbol is provided, the value returned for the property or method of the same name will be evaluated. The property will be required if the result of the conditional is truthy.

### Example:

```ruby
class Person < Hashie::Dash
  property :name, required: true
  property :age, required: true, message: 'must be set.'
  property :email
  property :phone, required: -> { email.nil? }, message: 'is required if email is not set.'
  property :pants, required: :weekday?, message: 'are only required on weekdays.'
  property :occupation, default: 'Rubyist'

  def weekday?
    [ Time.now.saturday?, Time.now.sunday? ].none?
  end
end

p = Person.new # => ArgumentError: The property 'name' is required for this Dash.
p = Person.new(name: 'Bob') # => ArgumentError: The property 'age' must be set.

p = Person.new(name: "Bob", age: 18)
p.name         # => 'Bob'
p.name = nil   # => ArgumentError: The property 'name' is required for this Dash.
p.age          # => 18
p.age = nil    # => ArgumentError: The property 'age' must be set.
p.email = 'abc@def.com'
p.occupation   # => 'Rubyist'
p.email        # => 'abc@def.com'
p[:awesome]    # => NoMethodError
p[:occupation] # => 'Rubyist'
p.update_attributes!(name: 'Trudy', occupation: 'Evil')
p.occupation   # => 'Evil'
p.name         # => 'Trudy'
p.update_attributes!(occupation: nil)
p.occupation   # => 'Rubyist'
```

Properties defined as symbols are not the same thing as properties defined as strings.

### Example:

```ruby
class Tricky < Hashie::Dash
  property :trick
  property 'trick'
end

p = Tricky.new(trick: 'one', 'trick' => 'two')
p.trick # => 'one', always symbol version
p[:trick] # => 'one'
p['trick'] # => 'two'
```

Note that accessing a property as a method always uses the symbol version.

```ruby
class Tricky < Hashie::Dash
  property 'trick'
end

p = Tricky.new('trick' => 'two')
p.trick # => NoMethodError
```

### Dash Extension: PropertyTranslation

The `Hashie::Extensions::Dash::PropertyTranslation` mixin extends a Dash with
the ability to remap keys from a source hash.

### Example from inconsistent APIs

Property translation is useful when you need to read data from another
application -- such as a Java API -- where the keys are named differently from
Ruby conventions.

```ruby
class PersonHash < Hashie::Dash
  include Hashie::Extensions::Dash::PropertyTranslation

  property :first_name, from: :firstName
  property :last_name, from: :lastName
  property :first_name, from: :f_name
  property :last_name, from: :l_name
end

person = PersonHash.new(firstName: 'Michael', l_name: 'Bleigh')
person[:first_name]  #=> 'Michael'
person[:last_name]   #=> 'Bleigh
```

### Example using translation lambdas

You can also use a lambda to translate the value. This is particularly useful
when you want to ensure the type of data you're wrapping.

```ruby
class DataModelHash < Hashie::Dash
  include Hashie::Extensions::Dash::PropertyTranslation

  property :id, transform_with: ->(value) { value.to_i }
  property :created_at, from: :created, with: ->(value) { Time.parse(value) }
end

model = DataModelHash.new(id: '123', created: '2014-04-25 22:35:28')
model.id.class          #=> Fixnum
model.created_at.class  #=> Time
```

### Mash and Rails 4 Strong Parameters

To enable compatibility with Rails 4 use the [hashie-forbidden_attributes](https://github.com/Maxim-Filimonov/hashie-forbidden_attributes) gem.

### Dash Extension: Coercion.

If you want to use `Hashie::Extensions::Coercion` together with `Dash` then
you may probably want to use `Hashie::Extensions::Dash::Coercion` instead.
This extension automatically includes `Hashie::Extensions::Coercion`
and also adds a convenient `:coerce` option to `property` so you can define coercion in one line
instead of using `property` and `coerce_key` separate:

```ruby
class UserHash < Hashie::Dash
  include Hashie::Extensions::Coercion

  property :id
  property :posts

  coerce_key :posts, Array[PostHash]
end
```

This is the same as:

```ruby
class UserHash < Hashie::Dash
  include Hashie::Extensions::Dash::Coercion

  property :id
  property :posts, coerce: Array[PostHash]
end
```

## Trash

A Trash is a Dash that allows you to translate keys on initialization. It mixes
in the PropertyTranslation mixin by default and is used like so:

```ruby
class Person < Hashie::Trash
  property :first_name, from: :firstName
end
```

This will automatically translate the <tt>firstName</tt> key to <tt>first_name</tt>
when it is initialized using a hash such as through:

```ruby
Person.new(firstName: 'Bob')
```

Trash also supports translations using lambda, this could be useful when dealing with external API's. You can use it in this way:

```ruby
class Result < Hashie::Trash
  property :id, transform_with: lambda { |v| v.to_i }
  property :created_at, from: :creation_date, with: lambda { |v| Time.parse(v) }
end
```

this will produce the following

```ruby
result = Result.new(id: '123', creation_date: '2012-03-30 17:23:28')
result.id.class         # => Fixnum
result.created_at.class # => Time
```

## Clash

Clash is a Chainable Lazy Hash that allows you to easily construct complex hashes using method notation chaining. This will allow you to use a more action-oriented approach to building options hashes.

Essentially, a Clash is a generalized way to provide much of the same kind of "chainability" that libraries like Arel or Rails 2.x's named_scopes provide.

### Example:

```ruby
c = Hashie::Clash.new
c.where(abc: 'def').order(:created_at)
c # => { where: { abc: 'def' }, order: :created_at }

# You can also use bang notation to chain into sub-hashes,
# jumping back up the chain with _end!
c = Hashie::Clash.new
c.where!.abc('def').ghi(123)._end!.order(:created_at)
c # => { where: { abc: 'def', ghi: 123 }, order: :created_at }

# Multiple hashes are merged automatically
c = Hashie::Clash.new
c.where(abc: 'def').where(hgi: 123)
c # => { where: { abc: 'def', hgi: 123 } }
```

## Rash

Rash is a Hash whose keys can be Regexps or Ranges, which will map many input keys to a value.

A good use case for the Rash is an URL router for a web framework, where URLs need to be mapped to actions; the Rash's keys match URL patterns, while the values call the action which handles the URL.

If the Rash's value is a `proc`, the `proc` will be automatically called with the regexp's MatchData (matched groups) as a block argument.

### Example:

```ruby

# Mapping names to appropriate greetings
greeting = Hashie::Rash.new( /^Mr./ => "Hello sir!", /^Mrs./ => "Evening, madame." )
greeting["Mr. Steve Austin"] # => "Hello sir!"
greeting["Mrs. Steve Austin"] # => "Evening, madame."

# Mapping statements to saucy retorts
mapper = Hashie::Rash.new(
  /I like (.+)/ => proc { |m| "Who DOESN'T like #{m[1]}?!" },
  /Get off my (.+)!/ => proc { |m| "Forget your #{m[1]}, old man!" }
)
mapper["I like traffic lights"] # => "Who DOESN'T like traffic lights?!"
mapper["Get off my lawn!"]      # => "Forget your lawn, old man!"
```

### Auto-optimized

**Note:** The Rash is automatically optimized every 500 accesses (which means that it sorts the list of Regexps, putting the most frequently matched ones at the beginning).

If this value is too low or too high for your needs, you can tune it by setting: `rash.optimize_every = n`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Copyright

Copyright (c) 2009-2014 Intridea, Inc. (http://intridea.com/) and [contributors](https://github.com/intridea/hashie/graphs/contributors).

MIT License. See [LICENSE](LICENSE) for details.
