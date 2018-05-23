# Custom mode

The `:custom` mode is the most configurable mode and honors almost all
options. It provides the most flexibility although it can not be configured to
be exactly like any of the other modes. Each mode has some special aspect that
makes it unique. For example, the `:object` mode has it's own unique format
for object dumping and loading. The `:compat` mode mimic the json gem
including methods called for encoding and inconsistencies between
`JSON.dump()`, `JSON.generate()`, and `JSON()`.

The `:custom` mode is the default mode. It can be configured either by passing
options to the `Oj.dump()` and `Oj.load()` methods or by modifying the default
options.

The ability to create objects from JSON object elements is supported and
considers the `:create_additions` option. Special treatment is given to the
`:create_id` though. If the `:create_id` is set to `"^o"` then the Oj internal
encoding and decoding is used. These are more efficient than calling out to a
`to_json` method or `create_json` method on the classes. Those method do not
have to exist for the `"^o"` behavior to be utilized. Any other `:create_id`
value behaves similar to the json gem by calling `to_json` and `create_json`
as appropriate.

