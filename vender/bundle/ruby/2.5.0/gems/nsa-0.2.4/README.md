# NSA (National Statsd Agency)

Listen to Rails `ActiveSupport::Notifications` and deliver to a [Statsd](https://github.com/reinh/statsd) backend.
This gem also supports writing your own custom collectors.

[![Gem Version](https://badge.fury.io/rb/nsa.svg)](https://badge.fury.io/rb/nsa)
[![Build Status](https://travis-ci.org/localshred/nsa.svg)](https://travis-ci.org/localshred/nsa)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "nsa"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nsa

## Usage

NSA comes packaged with collectors for ActionController, ActiveRecord, ActiveSupport Caching,
and Sidekiq.

To use this gem, simply get a reference to a statsd backend, then indicate which
collectors you'd like to run. Each `collect` method specifies a Collector to use
and the additional key namespace.

```ruby
statsd = ::Statsd.new(ENV["STATSD_HOST"], ENV["STATSD_PORT"])
application_name = ::Rails.application.class.parent_name.underscore
application_env = ENV["PLATFORM_ENV"] || ::Rails.env
statsd.namespace = [ application_name, application_env ].join(".")

::NSA.inform_statsd(statsd) do |informant|
  # Load :action_controller collector with a key prefix of :web
  informant.collect(:action_controller, :web)
  informant.collect(:active_record, :db)
  informant.collect(:cache, :cache)
  informant.collect(:sidekiq, :sidekiq)
end
```

## Built-in Collectors

### `:action_controller`

Listens to: `process_action.action_controller`

Metrics recorded:

+ Timing: `{ns}.{prefix}.{controller}.{action}.{format}.total_duration`
+ Timing: `{ns}.{prefix}.{controller}.{action}.{format}.db_time`
+ Timing: `{ns}.{prefix}.{controller}.{action}.{format}.view_time`
+ Increment: `{ns}.{prefix}.{controller}.{action}.{format}.status.{status_code}`

### `:active_record`

Listens to: `sql.active_record`

Metrics recorded:

+ Timing: `{ns}.{prefix}.tables.{table_name}.queries.delete.duration`
+ Timing: `{ns}.{prefix}.tables.{table_name}.queries.insert.duration`
+ Timing: `{ns}.{prefix}.tables.{table_name}.queries.select.duration`
+ Timing: `{ns}.{prefix}.tables.{table_name}.queries.update.duration`

### `:active_support_cache`

Listens to: `cache_*.active_suppport`

Metrics recorded:

+ Timing: `{ns}.{prefix}.delete.duration`
+ Timing: `{ns}.{prefix}.exist?.duration`
+ Timing: `{ns}.{prefix}.fetch_hit.duration`
+ Timing: `{ns}.{prefix}.generate.duration`
+ Timing: `{ns}.{prefix}.read_hit.duration`
+ Timing: `{ns}.{prefix}.read_miss.duration`
+ Timing: `{ns}.{prefix}.read_miss.duration`

### `:sidekiq`

Listens to: Sidekiq middleware, run before each job that is processed

Metrics recorded:

+ Time: `{ns}.{prefix}.{WorkerName}.processing_time`
+ Increment: `{ns}.{prefix}.{WorkerName}.success`
+ Increment: `{ns}.{prefix}.{WorkerName}.failure`
+ Gauge: `{ns}.{prefix}.queues.{queue_name}.enqueued`
+ Gauge: `{ns}.{prefix}.queues.{queue_name}.latency`
+ Gauge: `{ns}.{prefix}.dead_size`
+ Gauge: `{ns}.{prefix}.enqueued`
+ Gauge: `{ns}.{prefix}.failed`
+ Gauge: `{ns}.{prefix}.processed`
+ Gauge: `{ns}.{prefix}.processes_size`
+ Gauge: `{ns}.{prefix}.retry_size`
+ Gauge: `{ns}.{prefix}.scheduled_size`
+ Gauge: `{ns}.{prefix}.workers_size`

## Writing your own collector

Writing your own collector is very simple. To take advantage of the keyspace handling you must:

1. Create an object/module which responds to `collect`, taking the `key_prefix` as its only argument.
2. Include or extend your class/module with `NSA::Statsd::Publisher` or `NSA::Statsd::Publisher`.
3. Call any of the `statsd_*` prefixed methods provided by the included Publisher:

__`Publisher` methods:__

+ `statsd_count(key, value = 1, sample_rate = nil)`
+ `statsd_decrement(key, sample_rate = nil)`
+ `statsd_gauge(key, value = 1, sample_rate = nil)`
+ `statsd_increment(key, sample_rate = nil)`
+ `statsd_set(key, value = 1, sample_rate = nil)`
+ `statsd_time(key, sample_rate = nil, &block)`
+ `statsd_timing(key, value = 1, sample_rate = nil)`

__`AsyncPublisher` methods:__

+ `async_statsd_count(key, sample_rate = nil, &block)`
+ `async_statsd_gauge(key, sample_rate = nil, &block)`
+ `async_statsd_set(key, sample_rate = nil, &block)`
+ `async_statsd_time(key, sample_rate = nil, &block)`
+ `async_statsd_timing(key, sample_rate = nil, &block)`

___Note:___ When using the `AsyncPublisher`, the value is derived from the block. This is useful
when the value is not near at hand and has a relatively high cost to compute (e.g. db query)
and you don't want your current thread to wait.

For example, first define your collector. Our (very naive) example will write
a gauge metric every 10 seconds of the User count in the db.

```ruby
# Publishing User.count gauge using a collector
module UsersCollector
  extend ::NSA::Statsd::Publisher

  def self.collect(key_prefix)
    loop do
      statsd_gauge("count", ::User.count)
      sleep 10 # don't do this, obvi
    end
  end
end
```

Then let the informant know about it in some initializer:

```ruby
# file: config/initializers/statsd.rb

# $statsd =
NSA.inform_statsd($statsd) do |informant|
  # ...
  informant.collect(UserCollector, :users)
end
```

You could also implement the provided example not as a Collector, but using
`AsyncPublisher` directly in your ActiveRecord model:

```ruby
# Publishing User.count gauge using AsyncPublisher methods
class User <  ActiveRecord::Base
  include NSA::Statsd::AsyncPublisher

  after_commit :write_count_gauge, :on => [ :create, :destroy ]

  # ...

  private

  def write_count_gauge
    async_statsd_gauge("models.User.all.count") { ::User.count }
  end

end
```

Using this technique, publishing the `User.count` stat gauge will not hold up
the thread responsible for creating the record (and processing more callbacks).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/localshred/nsa.

