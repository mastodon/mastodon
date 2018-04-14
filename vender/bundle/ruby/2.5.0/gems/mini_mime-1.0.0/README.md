# MiniMime

Minimal mime type implementation for use with the mail and rest-client gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_mime'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_mime

## Usage

```
require 'mini_mime'

MiniMime.lookup_by_filename("a.txt").content_type
# => "text/plain"

MiniMime.lookup_by_content_type("text/plain").extension
# => "txt"

MiniMime.lookup_by_content_type("text/plain").binary?
# => false

```

## Performance

MiniMime is optimised to minimize memory usage. It keeps a cache of 100 mime type lookups (and 100 misses). There are benchmarks in the [bench directory](https://github.com/discourse/mini_mime/bench/bench.rb)

```
Memory stats for requiring mime/types/columnar
Total allocated: 9869358 bytes (109796 objects)
Total retained:  3138198 bytes (31165 objects)

Memory stats for requiring mini_mime
Total allocated: 58898 bytes (398 objects)
Total retained:  7784 bytes (62 objects)
Warming up --------------------------------------
cached content_type lookup MiniMime
                        52.136k i/100ms
content_type lookup Mime::Types
                        32.701k i/100ms
Calculating -------------------------------------
cached content_type lookup MiniMime
                        641.305k (± 3.2%) i/s -      3.232M in   5.045630s
content_type lookup Mime::Types
                        361.041k (± 1.5%) i/s -      1.831M in   5.073290s
Warming up --------------------------------------
uncached content_type lookup MiniMime
                         3.333k i/100ms
content_type lookup Mime::Types
                        33.177k i/100ms
Calculating -------------------------------------
uncached content_type lookup MiniMime
                         33.660k (± 1.7%) i/s -    169.983k in   5.051415s
content_type lookup Mime::Types
                        364.931k (± 2.8%) i/s -      1.825M in   5.004112s
```

As a general guideline, cached lookups are 2x faster than MIME::Types equivelent. Uncached lookups are 10x slower.


## Development

MiniMime uses the officially maintained list of mime types at [mime-types-data](https://github.com/mime-types/mime-types-data)repo to build the internal database.

To update the database run:

```ruby
bundle exec rake rebuild_db
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/discourse/mini_mime. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

