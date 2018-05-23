# Fog::Local

![Gem Version](https://badge.fury.io/rb/fog-local.svg)
[![Build Status](https://travis-ci.org/fog/fog-local.svg?branch=master)](https://travis-ci.org/fog/fog-local)
[![Dependency Status](https://gemnasium.com/fog/fog-local.svg)](https://gemnasium.com/fog/fog-local)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fog-local'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fog-local

## Usage

Initialise a `Fog::Storage` object using local provider

```ruby

storage = Fog::Storage.new({
  :local_root => '~/fog',
  :provider   => 'Local'
})

```

This can then be used like any other [Fog storage](http://fog.io/storage/).

```ruby
directory = storage.directories.create(:key => 'data')
directory.files.create(:body => 'Hello World!', :key  => 'hello_world.txt')
```

## Contributing

1. Fork it ( https://github.com/fog/fog-local/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
