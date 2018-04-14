# Oj Modes

Oj uses modes to switch the load and dump behavior. Initially Oj supported on
the :object mode which uses a format that allows Ruby object encoding and
decoding in a manner that lets almost any Ruby object be encoded and decoded
without monkey patching the object classes. From that start other demands were
made the were best met by giving Oj multiple modes of operation. The current
modes are:

 - `:strict`
 - `:null`
 - `:compat` or `:json`
 - `:rails`
 - `:object`
 - `:custom`

Since modes detemine what the JSON output will look like and alternatively
what Oj expects when the `Oj.load()` method is called, mixing the output and
input mode formats will most likely not behave as intended. If the object mode
is used for producing JSON then use object mode for reading. The same is true
for each mode. It is possible to mix but only for advanced users.

## :strict Mode

Strict mode follows the JSON specifications and only supports the JSON native
types, Boolean, nil, String, Hash, Array, and Numbers are encoded as
expected. Encountering any other type causes an Exception to be raised. This
is the safest mode as it is just simple translation, no code outside Oj or the
core Ruby is execution on loading. Very few options are supported by this mode
other than formatting options.

## :null Mode

Null mode is similar to the :strict mode except that a JSON null is inserted
if a non-native type is encountered instead of raising an Exception.

## :compat or :json Mode

The `:compat` mode mimics the json gem. The json gem is built around the use
of the `to_json(*)` method defined for a class. Oj attempts to provide the
same functionality by being a drop in replacement with a few
exceptions. [{file:JsonGem.md}](JsonGem.md) includes more details on
compatibility and use.

## :rails Mode

The `:rails` mode mimics the ActiveSupport version 5 encoder. Rails and
ActiveSupport are built around the use of the `as_json(*)` method defined for
a class. Oj attempts to provide the same functionality by being a drop in
replacement with a few exceptions. [{file:Rails.md}](Rails.md) includes
more details on compatibility and use.

## :object Mode

Object mode is for fast Ruby object serialization and deserialization. That
was the primary purpose of Oj when it was first developed. As such it is the
default mode unless changed in the Oj default options. In :object mode Oj
generates JSON that follows conventions which allow Class and other
information such as Object IDs for circular reference detection to be encoded
in a JSON document. The formatting follows the rules describe on the
[{file:Encoding.md}](Encoding.md) page.

## :custom Mode

Custom mode honors all options. It provides the most flexibility although it
can not be configured to be exactly like any of the other modes. Each mode has
some special aspect that makes it unique. For example, the `:object` mode has
it's own unique format for object dumping and loading. The `:compat` mode
mimic the json gem including methods called for encoding and inconsistencies
between `JSON.dump()`, `JSON.generate()`, and `JSON()`. More details on the
[{file:Custom.md}](Custom.md) page.

## :wab Mode

WAB mode ignores all options except the indent option. Performance of this
mode is on slightly better than the :strict and :null modes. It is included to
support the [WABuR](https://github.com/ohler55/wabur) project. More details on
the [{file:WAB.md}](WAB.md) page.

## Options Matrix

Not all options are available in all modes. The options matrix identifies the
options available in each mode. An `x` in the matrix indicates the option is
supported in that mode. A number indicates the footnotes describe additional
information.

    | Option                 | type    | :null   | :strict | :compat | :rails  | :object | :custom |  :wab   |
    | ---------------------- | ------- | ------- | ------- | ------- | ------- | ------- | ------- | ------- |
    | :allow_blank           | Boolean |         |         |       1 |       1 |         |       x |         |
    | :allow_gc              | Boolean |       x |       x |       x |       x |       x |       x |         |
    | :allow_invalid_unicode | Boolean |         |         |         |         |       x |       x |         |
    | :allow_nan             | Boolean |         |         |       x |         |       x |       x |         |
    | :array_class           | Class   |         |         |       x |       x |         |       x |         |
    | :array_nl              | String  |         |         |         |         |         |       x |         |
    | :ascii_only            | Boolean |       x |       x |       2 |       2 |       x |       x |         |
    | :auto_define           | Boolean |         |         |         |         |       x |       x |         |
    | :bigdecimal_as_decimal | Boolean |         |         |         |       3 |       x |       x |         |
    | :bigdecimal_load       | Boolean |         |         |         |         |         |       x |         |
    | :circular              | Boolean |       x |       x |       x |       x |       x |       x |         |
    | :class_cache           | Boolean |         |         |         |         |       x |       x |         |
    | :create_additions      | Boolean |         |         |       x |       x |         |       x |         |
    | :create_id             | String  |         |         |       x |       x |         |       x |         |
    | :empty_string          | Boolean |         |         |         |         |         |       x |         |
    | :escape_mode           | Symbol  |         |         |         |         |         |       x |         |
    | :float_precision       | Fixnum  |       x |       x |         |         |         |       x |         |
    | :hash_class            | Class   |         |         |       x |       x |         |       x |         |
    | :ignore                | Array   |         |         |         |         |       x |       x |         |
    | :indent                | Integer |       x |       x |       3 |       4 |       x |       x |       x |
    | :indent_str            | String  |         |         |       x |       x |         |       x |         |
    | :match_string          | Hash    |         |         |       x |       x |         |       x |         |
    | :max_nesting           | Fixnum  |       4 |       4 |       x |         |       5 |       4 |         |
    | :mode                  | Symbol  |       - |       - |       - |       - |       - |       - |         |
    | :nan                   | Symbol  |         |         |         |         |         |       x |         |
    | :nilnil                | Boolean |         |         |         |         |         |       x |         |
    | :object_class          | Class   |         |         |       x |         |         |       x |         |
    | :object_nl             | String  |         |         |       x |       x |         |       x |         |
    | :omit_nil              | Boolean |       x |       x |       x |       x |       x |       x |         |
    | :quirks_mode           | Boolean |         |         |       6 |         |         |       x |         |
    | :second_precision      | Fixnum  |         |         |         |         |       x |       x |         |
    | :space                 | String  |         |         |       x |       x |         |       x |         |
    | :space_before          | String  |         |         |       x |       x |         |       x |         |
    | :symbol_keys           | Boolean |       x |       x |       x |       x |       x |       x |         |
    | :trace                 | Boolean |       x |       x |       x |       x |       x |       x |       x |
    | :time_format           | Symbol  |         |         |         |         |       x |       x |         |
    | :use_as_json           | Boolean |         |         |         |         |         |       x |         |
    | :use_to_hash           | Boolean |         |         |         |         |         |       x |         |
    | :use_to_json           | Boolean |         |         |         |         |         |       x |         |
     --------------------------------------------------------------------------------------------------------

 1. :allow_blank an alias for :nilnil.

 2. The :ascii_only options is an undocumented json gem option.

 3. By default the bigdecimal_as decimal is not set and the default encoding
    for Rails is as a string. Setting the value to true will encode a
    BigDecimal as a number which breaks compatibility.

 4. The integer indent value in the default options will be honored by since
    the json gem expects a String type the indent in calls to 'to_json()',
    'Oj.generate()', or 'Oj.generate_fast()' expect a String and not an
    integer.

 5. The max_nesting option is for the json gem and rails only. It exists for
    compatibility. For other Oj dump modes the maximum nesting is set to over
    1000. If reference loops exist in the object being dumped then using the
    `:circular` option is a far better choice. It adds a slight overhead but
    detects an object that appears more than once in a dump and does not dump
    that object a second time.

 6. The quirks mode option is no longer supported in the most recent json
    gem. It is supported by Oj for backward compatibility with older json gem
    versions.

