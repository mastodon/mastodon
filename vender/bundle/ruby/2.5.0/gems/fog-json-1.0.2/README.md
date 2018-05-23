# Fog::Json

Extraction of the JSON parsing tools shared between a number of providers in
the 'fog' gem.

## Installation

Add this line to your application's Gemfile:

    gem "fog-json"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fog-json

## Usage

This gem extracts shared code from the `fog` gem (http://github.com/fog/fog)
that allows a standard interface to JSON encoding and decoding on top of
MultiJson but with errors support.

## Contributing

1. Fork it ( http://github.com/fog/fog-json/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

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
spec.add_dependency "fog-json", "~> 1.0"
```

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
