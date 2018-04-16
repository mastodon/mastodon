# Oj JSON Gem Compatibility

The `:compat` mode mimics the json gem. The json gem is built around the use
of the `to_json(*)` method defined for a class. Oj attempts to provide the
same functionality by being a drop in replacement for the 2.0.x version of the
json gem with a few exceptions. First a description of the json gem behavior
and then the differences between the json gem and the Oj.mimic_JSON behavior.

```ruby
require 'oj'

Oj.mimic_JSON()
Oj.add_to_json(Array, BigDecimal, Complex, Date, DateTime, Exception, Hash, Integer, OpenStruct, Range, Rational, Regexp, Struct, Time)
# Alternativel just call without arguments to add all available.
# Oj.add_to_json()
```

The json gem monkey patches core and base library classes with a `to_json(*)`
method. This allows calls such as `obj.to_json()` to be used to generate a
JSON string. The json gem also provides the JSON.generate(), JSON.dump(), and
JSON() functions. These functions generally act the same with some exceptions
such as JSON.generate(), JSON(), and to_json raise an exception when
attempting to encode infinity while JSON.dump() returns a the string
"Infinity". The String class is also monkey patched with to_json_raw() and
to_json_raw_object(). Oj in mimic mode mimics this behavior including the
seemly inconsistent behavior with NaN and Infinity.

Any class can define a to_json() method and JSON.generate(), JSON.dump(), and
JSON() functions will call that method when an object of that type is
encountered when traversing a Hash or Array. The core classes monkey patches
can be over-ridden but unless the to_json() method is called directory the
to_json() method will be ignored. Oj in mimic mode follow the same logic,

The json gem includes additions. These additions change the behavior of some
library and core classes. These additions also add the as_json() method and
json_create() class method. They are activated by requiring the appropriate
files. As an example, to get the modified to_json() for the Rational class
this line would be added.

```ruby
require 'json/add/rational'
```

Oj in mimic mode does not include these files although it will support the
modified to_json() methods. In keeping with the goal of providing a faster
encoder Oj offers an alternative. To activate faster addition version of the
to_json() method call

```ruby
Oj.add_to_json(Rational)
```

To revert back to the unoptimized version, just remove the Oj flag on that
class.

```ruby
Oj.remove_to_json(Rational)
```

The classes that can be added are:

 * Array
 * BigDecimal
 * Complex
 * Date
 * DateTime
 * Exception
 * Hash
 * Integer
 * OpenStruct
 * Range
 * Rational
 * Regexp
 * Struct
 * Time

The compatibility target version is 2.0.3. The json gem unit tests were used
to verify compatibility with a few changes to use Oj instead of the original
gem.
