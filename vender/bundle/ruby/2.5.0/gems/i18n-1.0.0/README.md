# Ruby I18n

[![Build Status](https://api.travis-ci.org/svenfuchs/i18n.svg?branch=master)](https://travis-ci.org/svenfuchs/i18n)

Ruby Internationalization and localization solution.

[See the Rails Guide](http://guides.rubyonrails.org/i18n.html) for an example of its usage. (Note: This library can be used independently from Rails.)

Features:

* translation and localization
* interpolation of values to translations (Ruby 1.9 compatible syntax)
* pluralization (CLDR compatible)
* customizable transliteration to ASCII
* flexible defaults
* bulk lookup
* lambdas as translation data
* custom key/scope separator
* custom exception handlers
* extensible architecture with a swappable backend

Pluggable features:

* Cache
* Pluralization: lambda pluralizers stored as translation data
* Locale fallbacks, RFC4647 compliant (optionally: RFC4646 locale validation)
* [Gettext support](https://github.com/svenfuchs/i18n/wiki/Gettext)
* Translation metadata

Alternative backends:

* Chain
* ActiveRecord (optionally: ActiveRecord::Missing and ActiveRecord::StoreProcs)
* KeyValue (uses active_support/json and cannot store procs)

For more information and lots of resources see [the 'Resources' page on the wiki](https://github.com/svenfuchs/i18n/wiki/Resources).

## Installation

```
gem install i18n
```

## Tests

You can run tests both with

* `rake test` or just `rake`
* run any test file directly, e.g. `ruby -Ilib:test test/api/simple_test.rb`

You can run all tests against all Gemfiles with

* `ruby test/run_all.rb`

The structure of the test suite is a bit unusual as it uses modules to reuse
particular tests in different test cases.

The reason for this is that we need to enforce the I18n API across various
combinations of extensions. E.g. the Simple backend alone needs to support
the same API as any combination of feature and/or optimization modules included
to the Simple backend. We test this by reusing the same API defition (implemented
as test methods) in test cases with different setups.

You can find the test cases that enforce the API in test/api. And you can find
the API definition test methods in test/api/tests.

All other test cases (e.g. as defined in test/backend, test/core_ext) etc.
follow the usual test setup and should be easy to grok.

## Authors

* [Sven Fuchs](http://www.artweb-design.de)
* [Joshua Harvey](http://www.workingwithrails.com/person/759-joshua-harvey)
* [Stephan Soller](http://www.arkanis-development.de)
* [Saimon Moore](http://saimonmoore.net)
* [Matt Aimonetti](https://matt.aimonetti.net/)

## Contributors

https://github.com/svenfuchs/i18n/graphs/contributors

## License

MIT License. See the included MIT-LICENSE file.
