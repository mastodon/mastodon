# Oj `:object` Mode Encoding

Object mode is for fast Ruby object serialization and deserialization. That
was the primary purpose of Oj when it was first developed. As such it is the
default mode unless changed in the Oj default options. In :object mode Oj
generates JSON that follows conventions which allow Class and other
information such as Object IDs for circular reference detection to be encoded
in a JSON document. The formatting follows these rules.

 * JSON native types, true, false, nil, String, Hash, Array, and Number are
   encoded normally.

 * A Symbol is encoded as a JSON string with a preceding `':'` character.

 * The `'^'` character denotes a special key value when in a JSON Object sequence.

 * A Ruby String that starts with `':'`or the sequence `'^i'` or `'^r'` are
   encoded by excaping the first character so that it appears as `'\u005e'` or
   `'\u003a'` instead of `':'` or `'^'`.

 * A `"^c"` JSON Object key indicates the value should be converted to a Ruby
   class. The sequence `{"^c":"Oj::Bag"}` is read as the Oj::Bag class.

 * A `"^t"` JSON Object key indicates the value should be converted to a Ruby
   Time. The sequence `{"^t":1325775487.000000}` is read as Jan 5, 2012 at
   23:58:07.

 * A `"^o"` JSON Object key indicates the value should be converted to a Ruby
   Object. The first entry in the JSON Object must be a class with the `"^o"`
   key. After that each entry is treated as a variable of the Object where the
   key is the variable name without the preceding `'@'`. An example is
   `{"^o":"Oj::Bag","x":58,"y":"marbles"}`. `"^O"`is the same except that it
   is for built in or odd classes that don't obey the normal Ruby
   rules. Examples are Rational, Date, and DateTime.

 * A `"^u"` JSON Object key indicates the value should be converted to a Ruby
   Struct. The first entry in the JSON Object must be a class with the
   `"^u"` key. After that each entry is is given a numeric position in the
   struct and that is used as the key in the JSON Object. An example is
   `{"^u":["Range",1,7,false]}`.

 * When encoding an Object, if the variable name does not begin with an
   `'@'`character then the name preceded by a `'~'` character. This occurs in
   the Exception class. An example is `{"^o":"StandardError","~mesg":"A
   Message","~bt":[".\/tests.rb:345:in 'test_exception'"]}`.

 * If a Hash entry has a key that is not a String or Symbol then the entry is
   encoded with a key of the form `"^#n"` where n is a hex number. The value
   is an Array where the first element is the key in the Hash and the second
   is the value. An example is `{"^#3":[2,5]}`.

 * A `"^i"` JSON entry in either an Object or Array is the ID of the Ruby
   Object being encoded. It is used when the :circular flag is set. It can
   appear in either a JSON Object or in a JSON Array. In an Object the
   `"^i"` key has a corresponding reference Fixnum. In an array the sequence
   will include an embedded reference number. An example is
   `{"^o":"Oj::Bag","^i":1,"x":["^i2",true],"me":"^r1"}`.

 * A `"^r"`JSON entry in an Object is a references to a Object or Array that
   already appears in the JSON String. It must match up with a previous
   `"^i"` ID. An example is `{"^o":"Oj::Bag","^i":1,"x":3,"me":"^r1"}`.

 * If an Array element is a String and starts with `"^i"` then the first
   character, the `'^'` is encoded as a hex character sequence. An example is
   `["\u005ei37",3]`.
