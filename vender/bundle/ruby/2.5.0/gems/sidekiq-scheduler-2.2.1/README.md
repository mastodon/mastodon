# sidekiq-scheduler

<p align="center">
  <a href="http://moove-it.github.io/sidekiq-scheduler/">
    <img src="https://moove-it.github.io/sidekiq-scheduler/images/small-logo.svg" width="468px" height="200px" alt="Sidekiq Scheduler" />
  </a>
</p>

<p align="center">
  <a href="https://badge.fury.io/rb/sidekiq-scheduler">
    <img src="https://badge.fury.io/rb/sidekiq-scheduler.svg" alt="Gem Version">
  </a>
  <a href="https://codeclimate.com/github/moove-it/sidekiq-scheduler">
    <img src="https://codeclimate.com/github/moove-it/sidekiq-scheduler/badges/gpa.svg" alt="Code Climate">
  </a>
  <a href="https://travis-ci.org/moove-it/sidekiq-scheduler">
    <img src="https://api.travis-ci.org/moove-it/sidekiq-scheduler.svg?branch=master" alt="Build Status">
  </a>
  <a href="https://coveralls.io/github/moove-it/sidekiq-scheduler?branch=master">
    <img src="https://coveralls.io/repos/moove-it/sidekiq-scheduler/badge.svg?branch=master&service=github" alt="Coverage Status">
  </a>
  <a href="https://inch-ci.org/github/moove-it/sidekiq-scheduler">
    <img src="https://inch-ci.org/github/moove-it/sidekiq-scheduler.svg?branch=master" alt="Documentation Coverage">
  </a>
  <a href="http://www.rubydoc.info/github/moove-it/sidekiq-scheduler">
    <img src="https://img.shields.io/badge/yard-docs-blue.svg" alt="Documentation">
  </a>
</p>

`sidekiq-scheduler` is an extension to [Sidekiq](http://github.com/mperham/sidekiq) that
pushes jobs in a scheduled way, mimicking cron utility.

## Installation

``` shell
gem install sidekiq-scheduler
```

## Usage

### Hello World


``` ruby
# hello-scheduler.rb

require 'sidekiq-scheduler'

class HelloWorld
  include Sidekiq::Worker

  def perform
    puts 'Hello world'
  end
end
```

``` yaml
# config/sidekiq.yml

:schedule:
  hello_world:
    cron: '0 * * * * *'   # Runs once per minute
    class: HelloWorld
```

Run sidekiq:

``` sh
sidekiq -r ./hello-scheduler.rb
```

You'll see the following output:

```
2016-12-10T11:53:08.561Z 6452 TID-ovouhwvm4 INFO: Loading Schedule
2016-12-10T11:53:08.561Z 6452 TID-ovouhwvm4 INFO: Scheduling HelloWorld {"cron"=>"0 * * * * *", "class"=>"HelloWorld"}
2016-12-10T11:53:08.562Z 6452 TID-ovouhwvm4 INFO: Schedules Loaded

2016-12-10T11:54:00.212Z 6452 TID-ovoulivew HelloWorld JID-b35f36a562733fcc5e58444d INFO: start
Hello world
2016-12-10T11:54:00.213Z 6452 TID-ovoulivew HelloWorld JID-b35f36a562733fcc5e58444d INFO: done: 0.001 sec

2016-12-10T11:55:00.287Z 6452 TID-ovoulist0 HelloWorld JID-b7e2b244c258f3cd153c2494 INFO: start
Hello world
2016-12-10T11:55:00.287Z 6452 TID-ovoulist0 HelloWorld JID-b7e2b244c258f3cd153c2494 INFO: done: 0.001 sec
```

## Configuration options

Configuration options are placed inside `sidekiq.yml` config file.

Available options are:

``` yaml
:dynamic: <if true the schedule can be modified in runtime [false by default]>
:dynamic_every: <if dynamic is true, the schedule is reloaded every interval [5s by default]>
:enabled: <enables scheduler if true [true by default]>
:scheduler:
  :listened_queues_only: <push jobs whose queue is being listened by sidekiq [false by default]>
```

## Schedule configuration

The schedule is configured through the `:schedule` config entry in the sidekiq config file:

``` yaml
:schedule:
  CancelAbandonedOrders:
    cron: '0 */5 * * * *'   # Runs when second = 0, every 5 minutes

  queue_documents_for_indexing:
    cron: '0 0 * * * *'   # Runs every hour

    # By default the job name will be taken as worker class name.
    # If you want to have a different job name and class name, provide the 'class' option
    class: QueueDocuments

    queue: slow
    args: ['*.pdf']
    description: "This job queues pdf content for indexing in solr"

    # Enable the `metadata` argument which will pass a Hash containing the schedule metadata
    # as the last argument of the `perform` method. `false` by default.
    include_metadata: true

    # Enable / disable a job. All jobs are enabled by default.
    enabled: true
```

### Schedule metadata
You can configure Sidekiq-scheduler to pass an argument with metadata about the scheduling process
to the worker's `perform` method.

In the configuration file add the following on each worker class entry:

```yaml

  SampleWorker:
    include_metadata: true
```

On your `perform` method, expect an additional argument:

```ruby
  def perform(args, ..., metadata)
    # Do something with the metadata
  end
```

The `metadata` hash contains the following keys:

```ruby
  metadata.keys =>
    [
      :scheduled_at # The epoch when the job was scheduled to run
    ]
```

## Schedule types

Supported types are `cron`, `every`, `interval`, `at`, `in`.

Cron, every, and interval types push jobs into sidekiq in a recurrent manner.

`cron` follows the same pattern as cron utility, with seconds resolution.

``` yaml
:schedule:
  HelloWorld:
    cron: '0 * * * * *' # Runs when second = 0
```

`every` triggers following a given frequency:

``` yaml
    every: '45m'    # Runs every 45 minutes
```

`interval` is similar to `every`, the difference between them is that `interval` type schedules the
next execution after the interval has elapsed counting from its last job enqueue.

At, and in types push jobs only once. `at` schedules in a point in time:
``` yaml
    at: '3001/01/01'
```

You can specify any string that `DateTime.parse` and `Chronic` understand. To enable Chronic
strings, you must add it as a dependency.

`in` triggers after a time duration has elapsed:

``` yaml
    in: 1h # pushes a sidekiq job in 1 hour, after start-up
```

You can provide options to `every` or `cron` via an Array:

``` yaml
    every: ['30s', first_in: '120s']
```

See https://github.com/jmettraux/rufus-scheduler for more information.

## Load the schedule from a different file

You can place the schedule configuration in a separate file from `config/sidekiq.yml`

``` yaml
# sidekiq_scheduler.yml

clear_leaderboards_contributors:
  cron: '0 30 6 * * 1'
  class: ClearLeaderboards
  queue: low
  args: contributors
  description: 'This job resets the weekly leaderboard for contributions'
```

Please notice that the `schedule` root key is not present in the separate file.

To load the schedule:

``` ruby
require 'sidekiq'
require 'sidekiq/scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('../../sidekiq_scheduler.yml', __FILE__))
    Sidekiq::Scheduler.reload_schedule!
  end
end
```

The above code can be placed in an initializer (in `config/initializers`) that runs every time the app starts up.

## Dynamic schedule

The schedule can be modified after startup. To add / update a schedule, you have to:

``` ruby
Sidekiq.set_schedule('heartbeat', { 'every' => ['1m'], 'class' => 'HeartbeatWorker' })
```

If the schedule did not exist it will be created, if it existed it will be updated.

When `:dynamic` flag is set to `true`, schedule changes are loaded every 5 seconds. Use the `:dynamic_every` flag for a different interval.

``` yaml
# config/sidekiq.yml
:dynamic: true
```

If `:dynamic` flag is set to `false`, you'll have to reload the schedule manually in sidekiq
side:

``` ruby
Sidekiq::Scheduler.reload_schedule!
```

Invoke `Sidekiq.get_schedule` to obtain the current schedule:

``` ruby
Sidekiq.get_schedule
#  => { 'every' => '1m', 'class' => 'HardWorker' }
```

## Time zones

Note that if you use the cron syntax, this will be interpreted as in the server time zone
rather than the `config.time_zone` specified in Rails.

You can explicitly specify the time zone that rufus-scheduler will use:

``` yaml
    cron: '0 30 6 * * 1 Europe/Stockholm'
```

Also note that `config.time_zone` in Rails allows for a shorthand (e.g. "Stockholm")
that rufus-scheduler does not accept. If you write code to set the scheduler time zone
from the `config.time_zone` value, make sure it's the right format, e.g. with:

``` ruby
ActiveSupport::TimeZone.find_tzinfo(Rails.configuration.time_zone).name
```

## Notes about running on Multiple Hosts

Under normal conditions, `cron` and `at` jobs are pushed once regardless of the number of `sidekiq-scheduler` running instances,
assumming that time deltas between hosts is less than 24 hours.

Non-normal conditions that could push a specific job multiple times are:
 - high cpu load + a high number of jobs scheduled at the same time, like 100 jobs
 - network / redis latency + 28 (see `MAX_WORK_THREADS` https://github.com/jmettraux/rufus-scheduler/blob/master/lib/rufus/scheduler.rb#L41) or more jobs scheduled within the same network latency window

`every`, `interval` and `in` jobs will be pushed once per host.

## Sidekiq Web Integration

sidekiq-scheduler provides an extension to the Sidekiq web interface that adds a `Recurring Jobs` page.

``` ruby
# config.ru

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

run Sidekiq::Web
```

![Sidekiq Web Integration](https://github.com/moove-it/sidekiq-scheduler/raw/master/images/recurring-jobs-ui-tab.png)

## The Spring preloader and Testing your initializer via Rails console

If you're pulling in your schedule from a YML file via an initializer as shown, be aware that the Spring application preloader included with Rails will interefere with testing via the Rails console.

**Spring will not reload initializers** unless the initializer is changed.  Therefore, if you're making a change to your YML schedule file and reloading Rails console to see the change, Spring will make it seem like your modified schedule is not being reloaded.

To see your updated schedule, be sure to reload Spring by stopping it prior to booting the Rails console.

Run `spring stop` to stop Spring.

For more information, see [this issue](https://github.com/Moove-it/sidekiq-scheduler/issues/35#issuecomment-48067183) and [Spring's README](https://github.com/rails/spring/blob/master/README.md).


## Manage tasks from Unicorn/Rails server

If you want start sidekiq-scheduler only from Unicorn/Rails, but not from sidekiq you can have
something like this in an initializer:

``` ruby
# config/initializers/sidekiq_scheduler.rb
require 'sidekiq/scheduler'

puts "Sidekiq.server? is #{Sidekiq.server?.inspect}"
puts "defined?(Rails::Server) is #{defined?(Rails::Server).inspect}"
puts "defined?(Unicorn) is #{defined?(Unicorn).inspect}"

if Rails.env == 'production' && (defined?(Rails::Server) || defined?(Unicorn))
  Sidekiq.configure_server do |config|

    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(File.expand_path('../../scheduler.yml', __FILE__))
      Sidekiq::Scheduler.reload_schedule!
    end
  end
else
  Sidekiq::Scheduler.enabled = false
  puts "Sidekiq::Scheduler.enabled is #{Sidekiq::Scheduler.enabled.inspect}"
end
```

## License

MIT License

## Copyright

Copyright 2013 - 2017 Moove-IT.
Copyright 2012 Morton Jonuschat.
Some parts copyright 2010 Ben VandenBos.
