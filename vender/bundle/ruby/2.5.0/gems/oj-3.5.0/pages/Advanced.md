# Advanced Features

Optimized JSON (Oj), as the name implies, was written to provide speed optimized
JSON handling. It was designed as a faster alternative to Yajl and other
common Ruby JSON parsers. So far it has achieved that, and is about 2 times faster
than any other Ruby JSON parser, and 3 or more times faster at serializing JSON.

Oj has several `dump` or serialization modes which control how Ruby `Object`s are
converted to JSON. These modes are set with the `:mode` option in either the
default options or as one of the options to the `dump` method. In addition to
the various options there are also alternative APIs for parsing JSON.

The fastest alternative parser API is the `Oj::Doc` API. The `Oj::Doc` API takes
a completely different approach by opening a JSON document and providing calls
to navigate around the JSON while it is open. With this approach, JSON access
can be well over 20 times faster than conventional JSON parsing.

The `Oj::Saj` and `Oj::ScHandler` APIs are callback parsers that
walk the JSON document depth first and makes callbacks for each element.
Both callback parser are useful when only portions of the JSON are of
interest. Performance up to 20 times faster than conventional JSON is
possible if only a few elements of the JSON are of interest.
