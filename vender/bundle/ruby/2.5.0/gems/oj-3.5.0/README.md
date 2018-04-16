# [![{}j](http://www.ohler.com/dev/images/oj_comet_64.svg)](http://www.ohler.com/oj) gem

[![Build Status](https://img.shields.io/travis/ohler55/oj/master.svg)](http://travis-ci.org/ohler55/oj?branch=master) [![AppVeyor](https://img.shields.io/appveyor/ci/ohler55/oj/master.svg)](https://ci.appveyor.com/project/ohler55/oj) ![Gem](https://img.shields.io/gem/v/oj.svg) ![Gem](https://img.shields.io/gem/dt/oj.svg)

A *fast* JSON parser and Object marshaller as a Ruby gem.

Version 3.0 is out! 3.0 provides better json gem and Rails compatibility. It
also provides additional optimization options.

## Using

```ruby
require 'oj'

h = { 'one' => 1, 'array' => [ true, false ] }
json = Oj.dump(h)

# json =
# {
#   "one":1,
#   "array":[
#     true,
#     false
#   ]
# }

h2 = Oj.load(json)
puts "Same? #{h == h2}"
# true
```

## Installation
```
gem install oj
```

or in Bundler:

```
gem 'oj'
```

## Further Reading

For more details on options, modes, advanced features, and more follow these
links.

 - [{file:Options.md}](pages/Options.md) for parse and dump options.
 - [{file:Modes.md}](pages/Modes.md) for details on modes for strict JSON compliance, mimicing the JSON gem, and mimicing Rails and ActiveSupport behavior.
 - [{file:JsonGem.md}](pages/JsonGem.md) includes more details on json gem compatibility and use.
 - [{file:Rails.md}](pages/Rails.md) includes more details on Rails and ActiveSupport compatibility and use.
 - [{file:Custom.md}](pages/Custom.md) includes more details on Custom mode.
 - [{file:Encoding.md}](pages/Encoding.md) describes the :object encoding format.
 - [{file:Compatibility.md}](pages/Compatibility.md) lists current compatibility with Rubys and Rails.
 - [{file:Advanced.md}](pages/Advanced.md) for fast parser and marshalling features.
 - [{file:Security.md}](pages/Security.md) for security considerations.

## Releases

See [{file:CHANGELOG.md}](CHANGELOG.md)

## Links

 - *Documentation*: http://www.ohler.com/oj/doc, http://rubydoc.info/gems/oj

- *GitHub* *repo*: https://github.com/ohler55/oj

- *RubyGems* *repo*: https://rubygems.org/gems/oj

Follow [@peterohler on Twitter](http://twitter.com/#!/peterohler) for announcements and news about the Oj gem.

#### Performance Comparisons

 - [Oj Strict Mode Performance](http://www.ohler.com/dev/oj_misc/performance_strict.html) compares Oj strict mode parser performance to other JSON parsers.

 - [Oj Compat Mode Performance](http://www.ohler.com/dev/oj_misc/performance_compat.html) compares Oj compat mode parser performance to other JSON parsers.

 - [Oj Object Mode Performance](http://www.ohler.com/dev/oj_misc/performance_object.html) compares Oj object mode parser performance to other marshallers.

 - [Oj Callback Performance](http://www.ohler.com/dev/oj_misc/performance_callback.html) compares Oj callback parser performance to other JSON parsers.

#### Links of Interest

 - *Fast XML parser and marshaller on RubyGems*: https://rubygems.org/gems/ox

 - *Fast XML parser and marshaller on GitHub*: https://github.com/ohler55/ox

 - [Need for Speed](http://www.ohler.com/dev/need_for_speed/need_for_speed.html) for an overview of how Oj::Doc was designed.

 - *OjC, a C JSON parser*: https://www.ohler.com/ojc also at https://github.com/ohler55/ojc

 - *Piper Push Cache, push JSON to browsers*: http://www.piperpushcache.com
