# Fog::Core

Shared classes and tests for fog providers and services.

[![Build Status](https://travis-ci.org/fog/fog-core.svg?branch=master)](https://travis-ci.org/fog/fog-core)

## Ruby version

Fog-core requires Ruby `2.0.0` or later.

Ruby `1.8` and `1.9` support was dropped in `fog-v2.0.0` as a backwards incompatible
change. Please use the later fog `1.x` versions if you require `1.8.7` or `1.9.x` support.

## Installation

Add this line to your application's Gemfile:

    gem 'fog-core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fog-core

### Ruby 1.9.3

Some of `fog-core`'s dependencies have dropped support for Ruby 1.9.3 in later
versions. Rather than limit all `fog` users to older but compatible versions,
if you are using 1.9.3 you will need to declare a compatible version in your
application's `Gemfile` like:

    gem "net-ssh", "< 3.0"

See `Gemfile.1.9.3` for the definitive list as tested by Travis.

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/fog/fog-core/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
