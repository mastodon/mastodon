# ruby-oembed

[![Gem](https://img.shields.io/gem/v/ruby-oembed.svg)](https://rubygems.org/gems/ruby-oembed)
[![Travis branch](https://img.shields.io/travis/ruby-oembed/ruby-oembed/master.svg)](https://travis-ci.org/ruby-oembed/ruby-oembed/branches)
[![Code Climate](https://img.shields.io/codeclimate/github/ruby-oembed/ruby-oembed.svg)](https://codeclimate.com/github/ruby-oembed/ruby-oembed)
[![Coveralls](https://coveralls.io/repos/github/ruby-oembed/ruby-oembed/badge.svg?branch=coveralls)](https://coveralls.io/github/ruby-oembed/ruby-oembed?branch=coveralls)
![Maintenance](https://img.shields.io/maintenance/yes/2017.svg)


An oEmbed consumer library written in Ruby, letting you easily get embeddable HTML representations of supported web pages, based on their URLs. See [oembed.com](http://oembed.com) for more about the protocol.

# Installation

  gem install ruby-oembed

# Get Started

## Built-in Providers

The easiest way to use this library is to make use of the built-in providers.

```ruby
OEmbed::Providers.register_all
resource = OEmbed::Providers.get('http://www.youtube.com/watch?v=2BYXBC8WQ5k')
resource.video? #=> true
resource.thumbnail_url #=> "http://i3.ytimg.com/vi/2BYXBC8WQ5k/hqdefault.jpg"
resource.html #=> <<-HTML
  <object width="425" height="344">
    <param name="movie" value="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1"></param>
    <param name="allowFullScreen" value="true"></param>
    <param name="allowscriptaccess" value="always"></param>
    <embed src="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1" type="application/x-shockwave-flash" width="425" height="344" allowscriptaccess="always" allowfullscreen="true"></embed>
  </object>
HTML
```

## Custom Providers

If you'd like to use a provider that isn't included in the library, it's easy to create one. Just provide the oEmbed API endpoint and URL scheme(s).

```ruby
my_provider = OEmbed::Provider.new("http://my.cool-service.com/api/oembed_endpoint.{format}")
my_provider << "http://*.cool-service.com/image/*"
my_provider << "http://*.cool-service.com/video/*"
```

You can then use your new custom provider *or* you can register it along with the rest of the built-in providers.

```ruby
resource = my_provider.get("http://a.cool-service.com/video/1") #=> OEmbed::Response
resource.provider.name #=> "My Cool Service"

OEmbed::Providers.register(my_provider)
resource = OEmbed::Providers.get("http://a.cool-service.com/video/2") #=> OEmbed::Response
```

## Fallback Providers

Last but not least, ruby-oembed supports [Noembed](https://noembed.com/), [Embedly](http://embed.ly), provider discovery. The first two are provider aggregators. Each supports a wide array of websites ranging from [Amazon.com](http://www.amazon.com) to [xkcd](http://www.xkcd.com). The later is part of the oEmbed specification that allows websites to advertise support for the oEmbed protocol.

```ruby
OEmbed::Providers.register_fallback(
  OEmbed::ProviderDiscovery,
  OEmbed::Providers::Noembed
)
OEmbed::Providers.get('https://www.xkcd.com/802/') #=> OEmbed::Response
```

## Formatters

This library works wonderfully on its own, but can get a speed boost by using 3rd party libraries to parse oEmbed data. To use a 3rd party Formatter, just be sure to require the library _before_ ruby-oembed (or include them in your Gemfile before ruby-oembed).

```ruby
require 'json'
require 'xmlsimple'
require 'oembed'

OEmbed::Formatter::JSON.backend #=> OEmbed::Formatter::JSON::Backends::JSONGem
OEmbed::Formatter::XML.backend  #=> OEmbed::Formatter::XML::Backends::XmlSimple
```

The following, optional, backends are currently supported:
* The [JSON implementation for Ruby](http://flori.github.com/json/)
* Rails' ActiveSupport::JSON (confirmed to work with Rails 3.0.x and should work with Rails 2.0+)
* [XmlSimple](http://xml-simple.rubyforge.org/)

# Lend a Hand

**Note:** Work is under way on a v1.0 of ruby-oembed. If you'd like to contribute, take a look at [the rubocop branch!](https://github.com/ruby-oembed/ruby-oembed/tree/rubocop)

Code for the ruby-oembed library is [hosted on GitHub](https://github.com/ruby-oembed/ruby-oembed).

```bash
# Get the code.
git clone git://github.com/ruby-oembed/ruby-oembed.git
cd ruby-oembed
# Install all development-related gems.
gem install bundler
bundle install
# Run the tests.
bundle exec rake
# or run the test continually
bundle exec guard
```

If you encounter any bug, feel free to [create an Issue](https://github.com/ruby-oembed/ruby-oembed/issues).

We gladly accept pull requests! Just [fork](http://help.github.com/forking/) the library and commit your changes along with relevant tests. Once you're happy with the changes, [send a pull request](http://help.github.com/pull-requests/).

We do our best to [keep our tests green](http://travis-ci.org/ruby-oembed/ruby-oembed)

# Contributors

Thanks to [all who have made contributions](https://github.com/ruby-oembed/ruby-oembed/contributors) to this gem, both large and small.

# License

This code is free to use under the terms of the MIT license.
