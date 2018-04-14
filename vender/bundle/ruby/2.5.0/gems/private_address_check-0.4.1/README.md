# PrivateAddressCheck

[![Build Status](https://travis-ci.org/jtdowney/private_address_check.svg?branch=master)](https://travis-ci.org/jtdowney/private_address_check)
[![Code Climate](https://codeclimate.com/github/jtdowney/private_address_check/badges/gpa.svg)](https://codeclimate.com/github/jtdowney/private_address_check)

Checks if a URL or hostname would cause a request to a private network (RFC 1918). This is useful in preventing attacks like [Server Side Request Forgery](https://cwe.mitre.org/data/definitions/918.html).

## Requirements

* Ruby >= 2.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'private_address_check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install private_address_check

## Usage

```ruby
require "private_address_check"

PrivateAddressCheck.private_address?("8.8.8.8") # => false
PrivateAddressCheck.private_address?("10.10.10.2") # => true
PrivateAddressCheck.private_address?("127.0.0.1") # => true
PrivateAddressCheck.private_address?("172.16.2.10") # => true
PrivateAddressCheck.private_address?("192.168.1.10") # => true
PrivateAddressCheck.private_address?("fd00::2") # => true
PrivateAddressCheck.resolves_to_private_address?("github.com") # => false
PrivateAddressCheck.resolves_to_private_address?("localhost") # => true

require "private_address_check/tcpsocket_ext"
require "net/http"
require "uri"

Net::HTTP.get_response(URI.parse("http://192.168.1.1")) # => attempts connection like normal

PrivateAddressCheck.only_public_connections do
  Net::HTTP.get_response(URI.parse("http://192.168.1.1"))
end
# => raises PrivateAddressCheck::PrivateConnectionAttemptedError
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jtdowney/private_address_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

