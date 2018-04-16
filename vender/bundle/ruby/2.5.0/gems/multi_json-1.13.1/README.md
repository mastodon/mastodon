# MultiJSON

[![Gem Version](http://img.shields.io/gem/v/multi_json.svg)][gem]
[![Build Status](http://travis-ci.org/intridea/multi_json.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/intridea/multi_json.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/intridea/multi_json.svg)][codeclimate]

Lots of Ruby libraries parse JSON and everyone has their favorite JSON coder.
Instead of choosing a single JSON coder and forcing users of your library to be
stuck with it, you can use MultiJSON instead, which will simply choose the
fastest available JSON coder. Here's how to use it:

```ruby
require 'multi_json'

MultiJson.load('{"abc":"def"}') #=> {"abc" => "def"}
MultiJson.load('{"abc":"def"}', :symbolize_keys => true) #=> {:abc => "def"}
MultiJson.dump({:abc => 'def'}) # convert Ruby back to JSON
MultiJson.dump({:abc => 'def'}, :pretty => true) # encoded in a pretty form (if supported by the coder)
```

When loading invalid JSON, MultiJSON will throw a `MultiJson::ParseError`. `MultiJson::DecodeError` and `MultiJson::LoadError` are aliases for backwards compatibility.

```ruby
begin
  MultiJson.load('{invalid json}')
rescue MultiJson::ParseError => exception
  exception.data # => "{invalid json}"
  exception.cause # => JSON::ParserError: 795: unexpected token at '{invalid json}'
end
```

`ParseError` instance has `cause` reader which contains the original exception.
It also has `data` reader with the input that caused the problem.

The `use` method, which sets the MultiJSON adapter, takes either a symbol or a
class (to allow for custom JSON parsers) that responds to both `.load` and `.dump`
at the class level.

When MultiJSON fails to load the specified adapter, it'll throw `MultiJson::AdapterError`
which inherits from `ArgumentError`.

MultiJSON tries to have intelligent defaulting. That is, if you have any of the
supported engines already loaded, it will utilize them before attempting to
load any. When loading, libraries are ordered by speed. First Oj, then Yajl,
then the JSON gem, then JSON pure. If no other JSON library is available,
MultiJSON falls back to [OkJson][], a simple, vendorable JSON parser.

## Supported JSON Engines

* [Oj][oj] Optimized JSON by Peter Ohler
* [Yajl][yajl] Yet Another JSON Library by Brian Lopez
* [JSON][json-gem] The default JSON gem with C-extensions (ships with Ruby 1.9+)
* [JSON Pure][json-gem] A Ruby variant of the JSON gem
* [NSJSONSerialization][nsjson] Wrapper for Apple's NSJSONSerialization in the Cocoa Framework (MacRuby only)
* [gson.rb][gson] A Ruby wrapper for google-gson library (JRuby only)
* [JrJackson][jrjackson] JRuby wrapper for Jackson (JRuby only)
* [OkJson][okjson] A simple, vendorable JSON parser

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0
* Ruby 2.1.10
* Ruby 2.2.9
* Ruby 2.4.3
* Ruby 2.5.0
* [JRuby][]
* [Rubinius][]
* [MacRuby][] (not tested on Travis CI)

If something doesn't work in one of these implementations, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be responsible for providing patches in a timely
fashion. If critical issues for a particular implementation exist at the time
of a major release, support for that Ruby version may be dropped.

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

```ruby
spec.add_dependency 'multi_json', '~> 1.0'
```

## Copyright
Copyright (c) 2010-2018 Michael Bleigh, Josh Kalderimis, Erik Michaels-Ober,
and Pavel Pravosud. See [LICENSE][] for details.

[codeclimate]: https://codeclimate.com/github/intridea/multi_json
[gem]: https://rubygems.org/gems/multi_json
[gemnasium]: https://gemnasium.com/intridea/multi_json
[gson]: https://github.com/avsej/gson.rb
[jrjackson]: https://github.com/guyboertje/jrjackson
[jruby]: http://www.jruby.org/
[json-gem]: https://github.com/flori/json
[json-pure]: https://github.com/flori/json
[license]: LICENSE.md
[macruby]: http://www.macruby.org/
[nsjson]: https://developer.apple.com/library/ios/#documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html
[oj]: https://github.com/ohler55/oj
[okjson]: https://github.com/kr/okjson
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[rubinius]: http://rubini.us/
[semver]: http://semver.org/
[travis]: http://travis-ci.org/intridea/multi_json
[yajl]: https://github.com/brianmario/yajl-ruby
