
# et-orbi

[![Build Status](https://secure.travis-ci.org/floraison/et-orbi.svg)](http://travis-ci.org/floraison/et-orbi)
[![Gem Version](https://badge.fury.io/rb/et-orbi.svg)](http://badge.fury.io/rb/et-orbi)

Time zones for [fugit](https://github.com/floraison/fugit) and for [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler). Urbi et Orbi.

`EtOrbi::EoTime` instances quack like Ruby `Time` instances, but their `#zone` returns a `TZInfo::TimeZone` instance.

Getting `EoTime` instances:
```ruby
require 'et-orbi'

EtOrbi.now
  # => #<EtOrbi::EoTime:0x007f94d94 ...>
EtOrbi.parse('2017-12-13 13:00:00 America/Jamaica')
  # => #<EtOrbi::EoTime:0x007f94d90 @zone=#<TZInfo::DataTimezone: America/Jamaica>...>
EtOrbi.make_time(Time.now)
  # => #<EtOrbi::EoTime:0x007f94d91 ...>

EtOrbi.make_time(2017, 1, 31, 12, 'Europe/Moscow').to_debug_s
  # => 'ot 2017-01-31 12:00:00 +03:00 dst:false'

EtOrbi::EoTime.new(0, 'UTC').to_s
  # => "1970-01-01 00:00:00 +0000"
EtOrbi::EoTime.new(0, 'Europe/Moscow').to_s
  # => "1970-01-01 03:00:00 +0300"
```

More about `EtOrbi::EoTime` instances:
```
eot = EtOrbi::EoTime.new(0, 'Europe/Moscow')

eot.to_local_time.class  # => Time
eot.to_local_time.to_s   # => "1970-01-01 09:00:00 +0900" (at least on my system)

# For the rest, EtOrbi::EoTime mimicks ::Time
```

Helper methods:
```ruby
require 'et-orbi'

EtOrbi.get_tzone('Europe/Vilnius')
  # => #<TZInfo::DataTimezone: Europe/Vilnius>
EtOrbi.local_tzone
  # => #<TZInfo::TimezoneProxy: Asia/Tokyo>

EtOrbi.platform_info
  # => "(etz:nil,tnz:\"JST\",tzid:nil,rv:\"2.2.6\",rp:\"x86_64-darwin14\",eov:\"1.0.1\",
  #      rorv:nil,astz:nil,debian:nil,centos:nil,osx:\"Asia/Tokyo\")"
    #
    # etz: ENV['TZ']
    # tnz: Time.now.zone
    # tzid: defined?(TZInfo::Data)
    # rv: RUBY_VERSION
    # rp: RUBY_PLATFORM
    # eov: EtOrbi::VERSION
    # rorv: Rails::VERSION::STRING
    # astz: ActiveSupport provided Time.zone
```

### Rails?

If Rails is present, `Time.zone` is provided and EtOrbi will use it.

Rails sets its timezone under `config/application.rb`.


## Related projects

### Sister projects

* [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) - a cron/at/in/every/interval in-process scheduler, in fact, it's the father project to this fugit project
* [fugit](https://github.com/floraison/fugit) - Time tools for flor and the floraison project. Cron parsing and occurrence computing. Timestamps and more.


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

