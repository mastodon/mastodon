# Oj Rails Compatibility

The `:rails` mode mimics the ActiveSupport version 5 encoder. Rails and
ActiveSupport are built around the use of the `as_json(*)` method defined for
a class. Oj attempts to provide the same functionality by being a drop in
replacement with a few exceptions.

```ruby
require 'oj'

Oj::Rails.set_encoder()
Oj::Rails.set_decoder()
Oj::Rails.optimize()
Oj::Rails.mimic_JSON()
```

or simply call

```ruby
Oj.optimize_rails()
```

Either of those steps will setup Oj to mimic Rails but it will not change the
default mode type as the mode type is only used when calling the Oj encoding
directly. If Rails mode is also desired then use the `Oj.default_options` to
change the default mode.

Some of the Oj options are supported as arguments to the encoder if called
from Oj::Rails.encode() but when using the Oj::Rails::Encoder class the
encode() method does not support optional arguments as required by the
ActiveSupport compliance guidelines. The general approach Rails takes for
configuring encoding options is to either set global values or to create a new
instance of the Encoder class and provide options in the initializer.

The globals that ActiveSupport uses for encoding are:

 * ActiveSupport::JSON::Encoding.use_standard_json_time_format
 * ActiveSupport::JSON::Encoding.escape_html_entities_in_json
 * ActiveSupport::JSON::Encoding.time_precision
 * ActiveSupport::JSON::Encoding.json_encoder

Those globals are aliased to also be accessed from the ActiveSupport module
directly so ActiveSupport::JSON::Encoding.time_precision can also be accessed
from ActiveSupport.time_precision. Oj makes use of these globals in mimicing
Rails after the Oj::Rails.set_encode() method is called. That also sets the
ActiveSupport.json_encoder to the Oj::Rails::Encoder class.

Options passed into a call to to_json() are passed to the as_json()
methods. These are mostly ignored by Oj and simply passed on without
modifications as per the guidelines. The exception to this are the options
specific to Oj such as the :circular option which it used to detect circular
references while encoding.

By default Oj acts like the ActiveSupport encoder and honors any changes in
the as_json() methods. There are some optimized Oj encoders for some
classes. When the optimized encoder it toggled the as_json() methods will not
be called for that class but instead the optimized version will be called. The
optimized version is the same as the ActiveSupport default encoding for a
given class. The optimized versions are toggled with the optimize() and
deoptimize() methods. There is a default optimized version for every class
that takes the visible attributes and encodes them but that may not be the
same as what Rails uses. Trial and error is the best approach for classes not
listed here.

The classes that can be put in optimized mode and are optimized when
Oj::Rails.optimize is called with no arguments are:

 * Array
 * BigDecimal
 * Float
 * Hash
 * Range
 * Regexp
 * Time
 * ActiveSupport::TimeWithZone
 * ActionController::Parameters
 * any class inheriting from ActiveRecord::Base
 * any other class where all attributes should be dumped

The ActiveSupport decoder is the JSON.parse() method. Calling the
Oj::Rails.set_decoder() method replaces that method with the Oj equivalent.

### Notes:

1. Optimized Floats set the significant digits to 16. This is different than
   Ruby which is used by the json gem and by Rails. Ruby varies the
   significant digits which can be either 16 or 17 depending on the value.

2. Optimized Hashs do not collapse keys that become the same in the output. As
   an example, a non-String object that has a to_s() method will become the
   return value of the to_s() method in the output without checking to see if
   that has already been used. This could occur is a mix of String and Symbols
   are used as keys or if a other non-String objects such as Numerics are mixed
   with numbers as Strings.

3. To verify Oj is being used turn on the Oj `:trace` option. Similar to the
   Ruby Tracer Oj will then print out trace information. Another approach is
   to turn on C extension tracing.  Set `tracer = TracePoint.new(:c_call) do
   |tp| p [tp.lineno, tp.event, tp.defined_class, tp.method_id] end` or, in
   older Rubies, set `Tracer.display_c_call = true`.

   For example:

     ```
     require 'active_support/core_ext'
     require 'active_support/json'
     require 'oj'
     Oj.optimize_rails
     tracer.enable { Time.now.to_json }
     # prints output including
     ....
     [20, :c_call, #<Class:Oj::Rails::Encoder>, :new]
     [20, :c_call, Oj::Rails::Encoder, :encode]
     ....
     => "\"2018-02-23T12:13:42.493-06:00\""
     ```
