# HTTP::FormData

[![Gem Version](https://badge.fury.io/rb/http-form_data.svg)](http://rubygems.org/gems/http-form_data)
[![Build Status](https://secure.travis-ci.org/httprb/form_data.svg?branch=master)](http://travis-ci.org/httprb/form_data)
[![Code Climate](https://codeclimate.com/github/httprb/form_data.svg)](https://codeclimate.com/github/httprb/form_data)
[![Coverage Status](https://coveralls.io/repos/httprb/form_data.rb/badge.svg?branch=master)](https://coveralls.io/r/httprb/form_data.rb)

Utility-belt to build form data request bodies.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http-form_data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-form_data


## Usage

``` ruby
require "http/form_data"

form = HTTP::FormData.create({
  :username     => "ixti",
  :avatar_file  => HTTP::FormData::File.new("/home/ixti/avatar.png")
})

# Assuming socket is an open socket to some HTTP server
socket << "POST /some-url HTTP/1.1\r\n"
socket << "Host: example.com\r\n"
socket << "Content-Type: #{form.content_type}\r\n"
socket << "Content-Length: #{form.content_length}\r\n"
socket << "\r\n"
socket << form.to_s
```

It's also possible to create a non-file part with Content-Type:

``` ruby
form = HTTP::FormData.create({
  :username     => HTTP::FormData::Part.new('{"a": 1}', content_type: 'application/json'),
  :avatar_file  => HTTP::FormData::File.new("/home/ixti/avatar.png")
})
```

## Supported Ruby Versions

This library aims to support and is [tested against][ci] the following Ruby
versions:

* Ruby 2.1.x
* Ruby 2.2.x
* Ruby 2.3.x
* Ruby 2.4.x
* JRuby 9.1.x.x

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer. Being a maintainer
entails making sure all tests run and pass on that implementation. When
something breaks on your implementation, you will be responsible for providing
patches in a timely fashion. If critical issues for a particular implementation
exist at the time of a major release, support for that Ruby version may be
dropped.


## Contributing

1. Fork it ( https://github.com/httprb/form_data.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Copyright

Copyright (c) 2015-2017 Alexey V Zapparov.
See [LICENSE.txt][license] for further details.


[ci]:       http://travis-ci.org/httprb/form_data.rb
[license]:  https://github.com/httprb/form_data.rb/blob/master/LICENSE.txt
