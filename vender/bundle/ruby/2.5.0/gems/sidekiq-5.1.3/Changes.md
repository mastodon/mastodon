# Sidekiq Changes

[Sidekiq Changes](https://github.com/mperham/sidekiq/blob/master/Changes.md) | [Sidekiq Pro Changes](https://github.com/mperham/sidekiq/blob/master/Pro-Changes.md) | [Sidekiq Enterprise Changes](https://github.com/mperham/sidekiq/blob/master/Ent-Changes.md)

5.1.3
-----------

- Fix version comparison so Ruby 2.2.10 works. [#3808, nateberkopec]

5.1.2
-----------

- Add link to docs in Web UI footer
- Fix crash on Ctrl-C in Windows [#3775, Bernica]
- Remove `freeze` calls on String constants. This is superfluous with Ruby
  2.3+ and `frozen_string_literal: true`. [#3759]
- Fix use of AR middleware outside of Rails [#3787]
- Sidekiq::Worker `sidekiq_retry_in` block can now return nil or 0 to use
  the default backoff delay [#3796, dsalahutdinov]

5.1.1
-----------

- Fix Web UI incompatibility with Redis 3.x gem [#3749]

5.1.0
-----------

- **NEW** Global death handlers - called when your job exhausts all
  retries and dies.  Now you can take action when a job fails permanently. [#3721]
- **NEW** Enable ActiveRecord query cache within jobs by default [#3718, sobrinho]
  This will prevent duplicate SELECTS; cache is cleared upon any UPDATE/INSERT/DELETE.
  See the issue for how to bypass the cache or disable it completely.
- Scheduler timing is now more accurate, 15 -> 5 seconds [#3734]
- Exceptions during the :startup event will now kill the process [#3717]
- Make `Sidekiq::Client.via` reentrant [#3715]
- Fix use of Sidekiq logger outside of the server process [#3714]
- Tweak `constantize` to better match Rails class lookup. [#3701, caffeinated-tech]

5.0.5
-----------

- Update gemspec to allow newer versions of the Redis gem [#3617]
- Refactor Worker.set so it can be memoized [#3602]
- Fix display of Redis URL in web footer, broken in 5.0.3 [#3560]
- Update `Sidekiq::Job#display_args` to avoid mutation [#3621]

5.0.4
-----------

- Fix "slow startup" performance regression from 5.0.2. [#3525]
- Allow users to disable ID generation since some redis providers disable the CLIENT command. [#3521]

5.0.3
-----------

- Fix overriding `class_attribute` core extension from ActiveSupport with Sidekiq one [PikachuEXE, #3499]
- Allow job logger to be overridden [AlfonsoUceda, #3502]
- Set a default Redis client identifier for debugging [#3516]
- Fix "Uninitialized constant" errors on startup with the delayed extensions [#3509]

5.0.2
-----------

- fix broken release, thanks @nateberkopec

5.0.1
-----------

- Fix incorrect server identity when daemonizing [jwilm, #3496]
- Work around error running Web UI against Redis Cluster [#3492]
- Remove core extensions, Sidekiq is now monkeypatch-free! [#3474]
- Reimplement Web UI's HTTP\_ACCEPT\_LANGUAGE parsing because the spec is utterly
  incomprehensible for various edge cases. [johanlunds, natematykiewicz, #3449]
- Update `class_attribute` core extension to avoid warnings
- Expose `job_hash_context` from `Sidekiq::Logging` to support log customization

5.0.0
-----------

- **BREAKING CHANGE** Job dispatch was refactored for safer integration with
  Rails 5.  The **Logging** and **RetryJobs** server middleware were removed and
  functionality integrated directly into Sidekiq::Processor.  These aren't
  commonly used public APIs so this shouldn't impact most users.
```
Sidekiq::Middleware::Server::RetryJobs -> Sidekiq::JobRetry
Sidekiq::Middleware::Server::Logging -> Sidekiq::JobLogger
```
- Quieting Sidekiq is now done via the TSTP signal, the USR1 signal is deprecated.
- The `delay` extension APIs are no longer available by default, you
  must opt into them.
- The Web UI is now BiDi and can render RTL languages like Arabic, Farsi and Hebrew.
- Rails 3.2 and Ruby 2.0 and 2.1 are no longer supported.
- The `SomeWorker.set(options)` API was re-written to avoid thread-local state. [#2152]
- Sidekiq Enterprise's encrypted jobs now display "[encrypted data]" in the Web UI instead
  of random hex bytes.
- Please see the [5.0 Upgrade notes](5.0-Upgrade.md) for more detail.

4.2.10
-----------

- Scheduled jobs can now be moved directly to the Dead queue via API [#3390]
- Fix edge case leading to job duplication when using Sidekiq Pro's
  reliability feature [#3388]
- Fix error class name display on retry page [#3348]
- More robust latency calculation [#3340]

4.2.9
-----------

- Rollback [#3303] which broke Heroku Redis users [#3311]
- Add support for TSTP signal, for Sidekiq 5.0 forward compatibility. [#3302]

4.2.8
-----------

- Fix rare edge case with Redis driver that can create duplicate jobs [#3303]
- Fix Rails 5 loading issue [#3275]
- Restore missing tooltips to timestamps in Web UI [#3310]
- Work on **Sidekiq 5.0** is now active! [#3301]

4.2.7
-----------

- Add new integration testing to verify code loading and job execution
  in development and production modes with Rails 4 and 5 [#3241]
- Fix delayed extensions in development mode [#3227, DarthSim]
- Use Worker's `retry` default if job payload does not have a retry
  attribute [#3234, mlarraz]

4.2.6
-----------

- Run Rails Executor when in production [#3221, eugeneius]

4.2.5
-----------

- Re-enable eager loading of all code when running non-development Rails 5. [#3203]
- Better root URL handling for zany web servers [#3207]

4.2.4
-----------

- Log errors coming from the Rails 5 reloader. [#3212, eugeneius]
- Clone job data so middleware changes don't appear in Busy tab

4.2.3
-----------

- Disable use of Rails 5's Reloader API in non-development modes, it has proven
  to be unstable under load [#3154]
- Allow disabling of Sidekiq::Web's cookie session to handle the
  case where the app provides a session already [#3180, inkstak]
```ruby
Sidekiq::Web.set :sessions, false
```
- Fix Web UI sharding support broken in 4.2.2. [#3169]
- Fix timestamps not updating during UI polling [#3193, shaneog]
- Relax rack-protection version to >= 1.5.0
- Provide consistent interface to exception handlers, changing the structure of the context hash. [#3161]

4.2.2
-----------

- Fix ever-increasing cookie size with nginx [#3146, cconstantine]
- Fix so Web UI works without trailing slash [#3158, timdorr]

4.2.1
-----------

- Ensure browser does not cache JSON/AJAX responses. [#3136]
- Support old Sinatra syntax for setting config [#3139]

4.2.0
-----------

- Enable development-mode code reloading.  **With Rails 5.0+, you don't need
  to restart Sidekiq to pick up your Sidekiq::Worker changes anymore!** [#2457]
- **Remove Sinatra dependency**.  Sidekiq's Web UI now uses Rack directly.
  Thank you to Sidekiq's newest committer, **badosu**, for writing the code
  and doing a lot of testing to ensure compatibility with many different
  3rd party plugins.  If your Web UI works with 4.1.4 but fails with
  4.2.0, please open an issue. [#3075]
- Allow tuning of concurrency with the `RAILS_MAX_THREADS` env var. [#2985]
  This is the same var used by Puma so you can tune all of your systems
  the same way:
```sh
web: RAILS_MAX_THREADS=5 bundle exec puma ...
worker: RAILS_MAX_THREADS=10 bundle exec sidekiq ...
```
Using `-c` or `config/sidekiq.yml` overrides this setting.  I recommend
adjusting your `config/database.yml` to use it too so connections are
auto-scaled:
```yaml
  pool: <%= ENV['RAILS_MAX_THREADS'] || 5 %>
```

4.1.4
-----------

- Unlock Sinatra so a Rails 5.0 compatible version may be used [#3048]
- Fix race condition on startup with JRuby [#3043]


4.1.3
-----------

- Please note the Redis 3.3.0 gem has a [memory leak](https://github.com/redis/redis-rb/issues/612),
  Redis 3.2.2 is recommended until that issue is fixed.
- Sinatra 1.4.x is now a required dependency, avoiding cryptic errors
  and old bugs due to people not upgrading Sinatra for years. [#3042]
- Fixed race condition in heartbeat which could rarely lead to lingering
  processes on the Busy tab. [#2982]
```ruby
# To clean up lingering processes, modify this as necessary to connect to your Redis.
# After 60 seconds, lingering processes should disappear from the Busy page.

require 'redis'
r = Redis.new(url: "redis://localhost:6379/0")
# uncomment if you need a namespace
#require 'redis-namespace'
#r = Redis::Namespace.new("foo", r)
r.smembers("processes").each do |pro|
  r.expire(pro, 60)
  r.expire("#{pro}:workers", 60)
end
```


4.1.2
-----------

- Fix Redis data leak with worker data when a busy Sidekiq process
  crashes.  You can find and expire leaked data in Redis with this
script:
```bash
$ redis-cli keys  "*:workers" | while read LINE ; do TTL=`redis-cli expire "$LINE" 60`; echo "$LINE"; done;
```
  Please note that `keys` can be dangerous to run on a large, busy Redis.  Caveat runner.
- Freeze all string literals with Ruby 2.3. [#2741]
- Client middleware can now stop bulk job push. [#2887]

4.1.1
-----------

- Much better behavior when Redis disappears and comes back. [#2866]
- Update FR locale [dbachet]
- Don't fill logfile in case of Redis downtime [#2860]
- Allow definition of a global retries_exhausted handler. [#2807]
```ruby
Sidekiq.configure_server do |config|
  config.default_retries_exhausted = -> (job, ex) do
    Sidekiq.logger.info "#{job['class']} job is now dead"
  end
end
```

4.1.0
-----------

- Tag quiet processes in the Web UI [#2757, jcarlson]
- Pass last exception to sidekiq\_retries\_exhausted block [#2787, Nowaker]
```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_retries_exhausted do |job, exception|
  end
end
```
- Add native support for ActiveJob's `set(options)` method allowing
you to override worker options dynamically.  This should make it
even easier to switch between ActiveJob and Sidekiq's native APIs [#2780]
```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(*args)
    # do something
  end
end

MyWorker.set(queue: 'high', retry: false).perform_async(1)
```

4.0.2
-----------

- Better Japanese translations
- Remove `json` gem dependency from gemspec. [#2743]
- There's a new testing API based off the `Sidekiq::Queues` namespace. All
  assertions made against the Worker class still work as expected.
  [#2676, brandonhilkert]
```ruby
assert_equal 0, Sidekiq::Queues["default"].size
HardWorker.perform_async("log")
assert_equal 1, Sidekiq::Queues["default"].size
assert_equal "log", Sidekiq::Queues["default"].first['args'][0]
Sidekiq::Queues.clear_all
```

4.0.1
-----------

- Yank new queue-based testing API [#2663]
- Fix invalid constant reference in heartbeat

4.0.0
-----------

- Sidekiq's internals have been completely overhauled for performance
  and to remove dependencies.  This has resulted in major speedups, as
  [detailed on my blog](http://www.mikeperham.com/2015/10/14/optimizing-sidekiq/).
- See the [4.0 upgrade notes](4.0-Upgrade.md) for more detail.

3.5.4
-----------

- Ensure exception message is a string [#2707]
- Revert racy Process.kill usage in sidekiqctl

3.5.3
-----------

- Adjust shutdown event to run in parallel with the rest of system shutdown. [#2635]

3.5.2
-----------

- **Sidekiq 3 is now in maintenance mode**, only major bugs will be fixed.
- The exception triggering a retry is now passed into `sidekiq_retry_in`,
  allowing you to retry more frequently for certain types of errors.
  [#2619, kreynolds]
```ruby
  sidekiq_retry_in do |count, ex|
    case ex
    when RuntimeError
      5 * count
    else
      10 * count
    end
  end
```

3.5.1
-----------

- **FIX MEMORY LEAK** Under rare conditions, threads may leak [#2598, gazay]
- Add Ukrainian locale [#2561, elrakita]
- Disconnect and retry Redis operations if we see a READONLY error [#2550]
- Add server middleware testing harness; see [wiki](https://github.com/mperham/sidekiq/wiki/Testing#testing-server-middleware) [#2534, ryansch]

3.5.0
-----------

- Polished new banner! [#2522, firedev]
- Upgrade to Celluloid 0.17. [#2420, digitalextremist]
- Activate sessions in Sinatra for CSRF protection, requires Rails
  monkeypatch due to rails/rails#15843. [#2460, jc00ke]

3.4.2
-----------

- Don't allow `Sidekiq::Worker` in ActiveJob::Base classes. [#2424]
- Safer display of job data in Web UI [#2405]
- Fix CSRF vulnerability in Web UI, thanks to Egor Homakov for
  reporting. [#2422] If you are running the Web UI as a standalone Rack app,
  ensure you have a [session middleware
configured](https://github.com/mperham/sidekiq/wiki/Monitoring#standalone):
```ruby
use Rack::Session::Cookie, :secret => "some unique secret string here"
```

3.4.1
-----------

- Lock to Celluloid 0.16


3.4.0
-----------

- Set a `created_at` attribute when jobs are created, set `enqueued_at` only
  when they go into a queue. Fixes invalid latency calculations with scheduled jobs.
  [#2373, mrsimo]
- Don't log timestamp on Heroku [#2343]
- Run `shutdown` event handlers in reverse order of definition [#2374]
- Rename and rework `poll_interval` to be simpler, more predictable [#2317, cainlevy]
  The new setting is `average_scheduled_poll_interval`.  To configure
  Sidekiq to look for scheduled jobs every 5 seconds, just set it to 5.
```ruby
Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 5
end
```

3.3.4
-----------

- **Improved ActiveJob integration** - Web UI now shows ActiveJobs in a
  nicer format and job logging shows the actual class name, requires
  Rails 4.2.2+ [#2248, #2259]
- Add Sidekiq::Process#dump\_threads API to trigger TTIN output [#2247]
- Web UI polling now uses Ajax to avoid page reload [#2266, davydovanton]
- Several Web UI styling improvements [davydovanton]
- Add Tamil, Hindi translations for Web UI [ferdinandrosario, tejasbubane]
- Fix Web UI to work with country-specific locales [#2243]
- Handle circular error causes [#2285,  eugenk]

3.3.3
-----------

- Fix crash on exit when Redis is down [#2235]
- Fix duplicate logging on startup
- Undeprecate delay extension for ActionMailer 4.2+ . [#2186]

3.3.2
-----------

- Add Sidekiq::Stats#queues back
- Allows configuration of dead job set size and timeout [#2173, jonhyman]
- Refactor scheduler enqueuing so Sidekiq Pro can override it. [#2159]

3.3.1
-----------

- Dumb down ActionMailer integration so it tries to deliver if possible [#2149]
- Stringify Sidekiq.default\_worker\_options's keys [#2126]
- Add random integer to process identity [#2113, michaeldiscala]
- Log Sidekiq Pro's Batch ID if available [#2076]
- Refactor Processor Redis usage to avoid redis/redis-rb#490 [#2094]
- Move /dashboard/stats to /stats.  Add /stats/queues. [moserke, #2099]
- Add processes count to /stats [ismaelga, #2141]
- Greatly improve speed of Sidekiq::Stats [ismaelga, #2142]
- Add better usage text for `sidekiqctl`.
- `Sidekiq::Logging.with_context` is now a stack so you can set your
  own job context for logging purposes [grosser, #2110]
- Remove usage of Google Fonts in Web UI so it loads in China [#2144]

3.3.0
-----------

- Upgrade to Celluloid 0.16 [#2056]
- Fix typo for generator test file name [dlackty, #2016]
- Add Sidekiq::Middleware::Chain#prepend [seuros, #2029]

3.2.6
-----------

- Deprecate delay extension for ActionMailer 4.2+ . [seuros, #1933]
- Poll interval tuning now accounts for dead processes [epchris, #1984]
- Add non-production environment to Web UI page titles [JacobEvelyn, #2004]

3.2.5
-----------

- Lock Celluloid to 0.15.2 due to bugs in 0.16.0.  This prevents the
  "hang on shutdown" problem with Celluloid 0.16.0.

3.2.4
-----------

- Fix issue preventing ActionMailer sends working in some cases with
  Rails 4. [pbhogan, #1923]

3.2.3
-----------

- Clean invalid bytes from error message before converting to JSON (requires Ruby 2.1+) [#1705]
- Add queues list for each process to the Busy page. [davetoxa, #1897]
- Fix for crash caused by empty config file. [jordan0day, #1901]
- Add Rails Worker generator, `rails g sidekiq:worker User` will create `app/workers/user_worker.rb`. [seuros, #1909]
- Fix Web UI rendering with huge job arguments [jhass, #1918]
- Minor refactoring of Sidekiq::Client internals, for Sidekiq Pro. [#1919]

3.2.2
-----------

- **This version of Sidekiq will no longer start on Ruby 1.9.**  Sidekiq
  3 does not support MRI 1.9 but we've allowed it to run before now.
- Fix issue which could cause Sidekiq workers to disappear from the Busy
  tab while still being active [#1884]
- Add "Back to App" button in Web UI.  You can set the button link via
  `Sidekiq::Web.app_url = 'http://www.mysite.com'` [#1875, seuros]
- Add process tag (`-g tag`) to the Busy page so you can differentiate processes at a glance. [seuros, #1878]
- Add "Kill" button to move retries directly to the DJQ so they don't retry. [seuros, #1867]

3.2.1
-----------

- Revert eager loading change for Rails 3.x apps, as it broke a few edge
  cases.

3.2.0
-----------

- **Fix issue which caused duplicate job execution in Rails 3.x**
  This issue is caused by [improper exception handling in ActiveRecord](https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L281) which changes Sidekiq's Shutdown exception into a database
  error, making Sidekiq think the job needs to be retried. **The fix requires Ruby 2.1**. [#1805]
- Update how Sidekiq eager loads Rails application code [#1791, jonleighton]
- Change logging timestamp to show milliseconds.
- Reverse sorting of Dead tab so newer jobs are listed first [#1802]

3.1.4
-----------

- Happy π release!
- Self-tuning Scheduler polling, we use heartbeat info to better tune poll\_interval [#1630]
- Remove all table column width rules, hopefully get better column formatting [#1747]
- Handle edge case where YAML can't be decoded in dev mode [#1761]
- Fix lingering jobs in Busy page on Heroku [#1764]

3.1.3
-----------

- Use ENV['DYNO'] on Heroku for hostname display, rather than an ugly UUID. [#1742]
- Show per-process labels on the Busy page, for feature tagging [#1673]


3.1.2
-----------

- Suitably chastised, @mperham reverts the Bundler change.


3.1.1
-----------

- Sidekiq::CLI now runs `Bundler.require(:default, environment)` to boot all gems
  before loading any app code.
- Sort queues by name in Web UI [#1734]


3.1.0
-----------

- New **remote control** feature: you can remotely trigger Sidekiq to quiet
  or terminate via API, without signals.  This is most useful on JRuby
  or Heroku which does not support the USR1 'quiet' signal.  Now you can
  run a rake task like this at the start of your deploy to quiet your
  set of Sidekiq processes. [#1703]
```ruby
namespace :sidekiq do
  task :quiet => :environment do
    Sidekiq::ProcessSet.new.each(&:quiet!)
  end
end
```
- The Web UI can use the API to quiet or stop all processes via the Busy page.
- The Web UI understands and hides the `Sidekiq::Extensions::Delay*`
  classes, instead showing `Class.method` as the Job. [#1718]
- Polish the Dashboard graphs a bit, update Rickshaw [brandonhilkert, #1725]
- The poll interval is now configurable in the Web UI [madebydna, #1713]
- Delay extensions can be removed so they don't conflict with
  DelayedJob: put `Sidekiq.remove_delay!` in your initializer. [devaroop, #1674]


3.0.2
-----------

- Revert gemfile requirement of Ruby 2.0.  JRuby 1.7 calls itself Ruby
  1.9.3 and broke with this requirement.

3.0.1
-----------

- Revert pidfile behavior from 2.17.5: Sidekiq will no longer remove its own pidfile
  as this is a race condition when restarting. [#1470, #1677]
- Show warning on the Queues page if a queue is paused [#1672]
- Only activate the ActiveRecord middleware if ActiveRecord::Base is defined on boot. [#1666]
- Add ability to disable jobs going to the DJQ with the `dead` option.
```ruby
sidekiq_options :dead => false, :retry => 5
```
- Minor fixes


3.0.0
-----------

Please see [3.0-Upgrade.md](3.0-Upgrade.md) for more comprehensive upgrade notes.

- **Dead Job Queue** - jobs which run out of retries are now moved to a dead
  job queue.  These jobs must be retried manually or they will expire
  after 6 months or 10,000 jobs.  The Web UI contains a "Dead" tab
  exposing these jobs.  Use `sidekiq_options :retry => false` if you
don't wish jobs to be retried or put in the DJQ.  Use
`sidekiq_options :retry => 0` if you don't want jobs to retry but go
straight to the DJQ.
- **Process Lifecycle Events** - you can now register blocks to run at
  certain points during the Sidekiq process lifecycle: startup, quiet and
  shutdown.
```ruby
Sidekiq.configure_server do |config|
  config.on(:startup) do
    # do something
  end
end
```
- **Global Error Handlers** - blocks of code which handle errors that
  occur anywhere within Sidekiq, not just within middleware.
```ruby
Sidekiq.configure_server do |config|
  config.error_handlers << proc {|ex,ctx| ... }
end
```
- **Process Heartbeat** - each Sidekiq process will ping Redis every 5
  seconds to give a summary of the Sidekiq population at work.
- The Workers tab is now renamed to Busy and contains a list of live
  Sidekiq processes and jobs in progress based on the heartbeat.
- **Shardable Client** - Sidekiq::Client instances can use a custom
  Redis connection pool, allowing very large Sidekiq installations to scale by
  sharding: sending different jobs to different Redis instances.
```ruby
client = Sidekiq::Client.new(ConnectionPool.new { Redis.new })
client.push(...)
```
```ruby
Sidekiq::Client.via(ConnectionPool.new { Redis.new }) do
  FooWorker.perform_async
  BarWorker.perform_async
end
```
  **Sharding support does require a breaking change to client-side
middleware, see 3.0-Upgrade.md.**
- New Chinese, Greek, Swedish and Czech translations for the Web UI.
- Updated most languages translations for the new UI features.
- **Remove official Capistrano integration** - this integration has been
  moved into the [capistrano-sidekiq](https://github.com/seuros/capistrano-sidekiq) gem.
- **Remove official support for MRI 1.9** - Things still might work but
  I no longer actively test on it.
- **Remove built-in support for Redis-to-Go**.
  Heroku users: `heroku config:set REDIS_PROVIDER=REDISTOGO_URL`
- **Remove built-in error integration for Airbrake, Honeybadger, ExceptionNotifier and Exceptional**.
  Each error gem should provide its own Sidekiq integration.  Update your error gem to the latest
  version to pick up Sidekiq support.
- Upgrade to connection\_pool 2.0 which now creates connections lazily.
- Remove deprecated Sidekiq::Client.registered\_\* APIs
- Remove deprecated support for the old Sidekiq::Worker#retries\_exhausted method.
- Removed 'sidekiq/yaml\_patch', this was never documented or recommended.
- Removed --profile option, #1592
- Remove usage of the term 'Worker' in the UI for clarity.  Users would call both threads and
  processes 'workers'.  Instead, use "Thread", "Process" or "Job".

2.17.7
-----------

- Auto-prune jobs older than one hour from the Workers page [#1508]
- Add Sidekiq::Workers#prune which can perform the auto-pruning.
- Fix issue where a job could be lost when an exception occurs updating
  Redis stats before the job executes [#1511]

2.17.6
-----------

- Fix capistrano integration due to missing pidfile. [#1490]

2.17.5
-----------

- Automatically use the config file found at `config/sidekiq.yml`, if not passed `-C`. [#1481]
- Store 'retried\_at' and 'failed\_at' timestamps as Floats, not Strings. [#1473]
- A `USR2` signal will now reopen _all_ logs, using IO#reopen. Thus, instead of creating a new Logger object,
  Sidekiq will now just update the existing Logger's file descriptor [#1163].
- Remove pidfile when shutting down if started with `-P` [#1470]

2.17.4
-----------

- Fix JID support in inline testing, #1454
- Polish worker arguments display in UI, #1453
- Marshal arguments fully to avoid worker mutation, #1452
- Support reverse paging sorted sets, #1098


2.17.3
-----------

- Synchronously terminates the poller and fetcher to fix a race condition in bulk requeue during shutdown [#1406]

2.17.2
-----------

- Fix bug where strictly prioritized queues might be processed out of
  order [#1408]. A side effect of this change is that it breaks a queue
  declaration syntax that worked, although only because of a bug—it was
  never intended to work and never supported. If you were declaring your
  queues as a  comma-separated list, e.g. `sidekiq -q critical,default,low`,
  you must now use the `-q` flag before each queue, e.g.
  `sidekiq -q critical -q default -q low`.

2.17.1
-----------

- Expose `delay` extension as `sidekiq_delay` also.  This allows you to
  run Delayed::Job and Sidekiq in the same process, selectively porting
  `delay` calls to `sidekiq_delay`.  You just need to ensure that
  Sidekiq is required **before** Delayed::Job in your Gemfile. [#1393]
- Bump redis client required version to 3.0.6
- Minor CSS fixes for Web UI

2.17.0
-----------

- Change `Sidekiq::Client#push_bulk` to return an array of pushed `jid`s. [#1315, barelyknown]
- Web UI refactoring to use more API internally (yummy dogfood!)
- Much faster Sidekiq::Job#delete performance for larger queue sizes
- Further capistrano 3 fixes
- Many misc minor fixes

2.16.1
-----------

- Revert usage of `resolv-replace`.  MRI's native DNS lookup releases the GIL.
- Fix several Capistrano 3 issues
- Escaping dynamic data like job args and error messages in Sidekiq Web UI. [#1299, lian]

2.16.0
-----------

- Deprecate `Sidekiq::Client.registered_workers` and `Sidekiq::Client.registered_queues`
- Refactor Sidekiq::Client to be instance-based [#1279]
- Pass all Redis options to the Redis driver so Unix sockets
  can be fully configured. [#1270, salimane]
- Allow sidekiq-web extensions to add locale paths so extensions
  can be localized. [#1261, ondrejbartas]
- Capistrano 3 support [#1254, phallstrom]
- Use Ruby's `resolv-replace` to enable pure Ruby DNS lookups.
  This ensures that any DNS resolution that takes place in worker
  threads won't lock up the entire VM on MRI. [#1258]

2.15.2
-----------

- Iterating over Sidekiq::Queue and Sidekiq::SortedSet will now work as
  intended when jobs are deleted [#866, aackerman]
- A few more minor Web UI fixes [#1247]

2.15.1
-----------

- Fix several Web UI issues with the Bootstrap 3 upgrade.

2.15.0
-----------

- The Core Sidekiq actors are now monitored.  If any crash, the
  Sidekiq process logs the error and exits immediately.  This is to
  help prevent "stuck" Sidekiq processes which are running but don't
  appear to be doing any work. [#1194]
- Sidekiq's testing behavior is now dynamic.  You can choose between
  `inline` and `fake` behavior in your tests. See
[Testing](https://github.com/mperham/sidekiq/wiki/Testing) for detail. [#1193]
- The Retries table has a new column for the error message.
- The Web UI topbar now contains the status and live poll button.
- Orphaned worker records are now auto-vacuumed when you visit the
  Workers page in the Web UI.
- Sidekiq.default\_worker\_options allows you to configure default
  options for all Sidekiq worker types.

```ruby
Sidekiq.default_worker_options = { 'queue' => 'default', 'backtrace' => true }
```
- Added two Sidekiq::Client class methods for compatibility with resque-scheduler:
  `enqueue_to_in` and `enqueue_in` [#1212]
- Upgrade Web UI to Bootstrap 3.0. [#1211, jeffboek]

2.14.1
-----------

- Fix misc Web UI issues due to ERB conversion.
- Bump redis-namespace version due to security issue.

2.14.0
-----------

- Removed slim gem dependency, Web UI now uses ERB [Locke23rus, #1120]
- Fix more race conditions in Web UI actions
- Don't reset Job enqueued\_at when retrying
- Timestamp tooltips in the Web UI should use UTC
- Fix invalid usage of handle\_exception causing issues in Airbrake
  [#1134]


2.13.1
-----------

- Make Sidekiq::Middleware::Chain Enumerable
- Make summary bar and graphs responsive [manishval, #1025]
- Adds a job status page for scheduled jobs [jonhyman]
- Handle race condition in retrying and deleting jobs in the Web UI
- The Web UI relative times are now i18n. [MadRabbit, #1088]
- Allow for default number of retry attempts to be set for
  `Sidekiq::Middleware::Server::RetryJobs` middleware. [czarneckid] [#1091]

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => 10
  end
end
```


2.13.0
-----------

- Adding button to move scheduled job to main queue [guiceolin, #1020]
- fix i18n support resetting saved locale when job is retried [#1011]
- log rotation via USR2 now closes the old logger [#1008]
- Add ability to customize retry schedule, like so [jmazzi, #1027]

```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_retry_in { |count| count * 2 }
end
```
- Redesign Worker#retries\_exhausted callback to use same form as above [jmazzi, #1030]

```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_retries_exhausted do |msg|
    Rails.logger.error "Failed to process #{msg['class']} with args: #{msg['args']}"
  end
end
```

2.12.4
-----------

- Fix error in previous release which crashed the Manager when a
  Processor died.

2.12.3
-----------

- Revert back to Celluloid's TaskFiber for job processing which has proven to be more
  stable than TaskThread. [#985]
- Avoid possible lockup during hard shutdown [#997]

At this point, if you are experiencing stability issues with Sidekiq in
Ruby 1.9, please try Ruby 2.0.  It seems to be more stable.

2.12.2
-----------

- Relax slim version requirement to >= 1.1.0
- Refactor historical stats to use TTL, not explicit cleanup. [grosser, #971]

2.12.1
-----------

- Force Celluloid 0.14.1 as 0.14.0 has a serious bug. [#954]
- Scheduled and Retry jobs now use Sidekiq::Client to push
  jobs onto the queue, so they use client middleware. [dimko, #948]
- Record the timestamp when jobs are enqueued. Add
  Sidekiq::Job#enqueued\_at to query the time. [mariovisic, #944]
- Add Sidekiq::Queue#latency - calculates diff between now and
  enqueued\_at for the oldest job in the queue.
- Add testing method `perform_one` that dequeues and performs a single job.
  This is mainly to aid testing jobs that spawn other jobs. [fumin, #963]

2.12.0
-----------

- Upgrade to Celluloid 0.14, remove the use of Celluloid's thread
  pool.  This should halve the number of threads in each Sidekiq
  process, thus requiring less resources. [#919]
- Abstract Celluloid usage to Sidekiq::Actor for testing purposes.
- Better handling for Redis downtime when fetching jobs and shutting
  down, don't print exceptions every second and print success message
  when Redis is back.
- Fix unclean shutdown leading to duplicate jobs [#897]
- Add Korean locale [#890]
- Upgrade test suite to Minitest 5
- Remove usage of `multi_json` as `json` is now robust on all platforms.

2.11.2
-----------

- Fix Web UI when used without Rails [#886]
- Add Sidekiq::Stats#reset [#349]
- Add Norwegian locale.
- Updates for the JA locale.

2.11.1
-----------

- Fix timeout warning.
- Add Dutch web UI locale.

2.11.0
-----------

- Upgrade to Celluloid 0.13. [#834]
- Remove **timeout** support from `sidekiq_options`.  Ruby's timeout
  is inherently unsafe in a multi-threaded application and was causing
  stability problems for many.  See http://bit.ly/OtYpK
- Add Japanese locale for Web UI [#868]
- Fix a few issues with Web UI i18n.

2.10.1
-----------

- Remove need for the i18n gem. (brandonhilkert)
- Improve redis connection info logging on startup for debugging
purposes [#858]
- Revert sinatra/slim as runtime dependencies
- Add `find_job` method to sidekiq/api


2.10.0
-----------

- Refactor algorithm for putting scheduled jobs onto the queue [#843]
- Fix scheduler thread dying due to incorrect error handling [#839]
- Fix issue which left stale workers if Sidekiq wasn't shutdown while
quiet. [#840]
- I18n for web UI.  Please submit translations of `web/locales/en.yml` for
your own language. [#811]
- 'sinatra', 'slim' and 'i18n' are now gem dependencies for Sidekiq.


2.9.0
-----------

- Update 'sidekiq/testing' to work with any Sidekiq::Client call. It
  also serializes the arguments as using Redis would. [#713]
- Raise a Sidekiq::Shutdown error within workers which don't finish within the hard
  timeout.  This is to prevent unwanted database transaction commits. [#377]
- Lazy load Redis connection pool, you no longer need to specify
  anything in Passenger or Unicorn's after_fork callback [#794]
- Add optional Worker#retries_exhausted hook after max retries failed. [jkassemi, #780]
- Fix bug in pagination link to last page [pitr, #774]
- Upstart scripts for multiple Sidekiq instances [dariocravero, #763]
- Use select via pipes instead of poll to catch signals [mrnugget, #761]

2.8.0
-----------

- I18n support!  Sidekiq can optionally save and restore the Rails locale
  so it will be properly set when your jobs execute.  Just include
  `require 'sidekiq/middleware/i18n'` in your sidekiq initializer. [#750]
- Fix bug which could lose messages when using namespaces and the message
needs to be requeued in Redis. [#744]
- Refactor Redis namespace support [#747].  The redis namespace can no longer be
  passed via the config file, the only supported way is via Ruby in your
  initializer:

```ruby
sidekiq_redis = { :url => 'redis://localhost:3679', :namespace => 'foo' }
Sidekiq.configure_server { |config| config.redis = sidekiq_redis }
Sidekiq.configure_client { |config| config.redis = sidekiq_redis }
```

A warning is printed out to the log if a namespace is found in your sidekiq.yml.


2.7.5
-----------

- Capistrano no longer uses daemonization in order to work with JRuby [#719]
- Refactor signal handling to work on Ruby 2.0 [#728, #730]
- Fix dashboard refresh URL [#732]

2.7.4
-----------

- Fixed daemonization, was broken by some internal refactoring in 2.7.3 [#727]

2.7.3
-----------

- Real-time dashboard is now the default web page
- Make config file optional for capistrano
- Fix Retry All button in the Web UI

2.7.2
-----------

- Remove gem signing infrastructure.  It was causing Sidekiq to break
when used via git in Bundler.  This is why we can't have nice things. [#688]


2.7.1
-----------

- Fix issue with hard shutdown [#680]


2.7.0
-----------

- Add -d daemonize flag, capistrano recipe has been updated to use it [#662]
- Support profiling via `ruby-prof` with -p.  When Sidekiq is stopped
  via Ctrl-C, it will output `profile.html`.  You must add `gem 'ruby-prof'` to your Gemfile for it to work.
- Dynamically update Redis stats on dashboard [brandonhilkert]
- Add Sidekiq::Workers API giving programmatic access to the current
  set of active workers.

```
workers = Sidekiq::Workers.new
workers.size => 2
workers.each do |name, work|
  # name is a unique identifier per Processor instance
  # work is a Hash which looks like:
  # { 'queue' => name, 'run_at' => timestamp, 'payload' => msg }
end
```

- Allow environment-specific sections within the config file which
override the global values [dtaniwaki, #630]

```
---
:concurrency:  50
:verbose:      false
staging:
  :verbose:      true
  :concurrency:  5
```


2.6.5
-----------

- Several reliability fixes for job requeueing upon termination [apinstein, #622, #624]
- Fix typo in capistrano recipe
- Add `retry_queue` option so retries can be given lower priority [ryanlower, #620]

```ruby
sidekiq_options queue: 'high', retry_queue: 'low'
```

2.6.4
-----------

- Fix crash upon empty queue [#612]

2.6.3
-----------

- sidekiqctl exits with non-zero exit code upon error [jmazzi]
- better argument validation in Sidekiq::Client [karlfreeman]

2.6.2
-----------

- Add Dashboard beacon indicating when stats are updated. [brandonhilkert, #606]
- Revert issue with capistrano restart. [#598]

2.6.1
-----------

- Dashboard now live updates summary stats also. [brandonhilkert, #605]
- Add middleware chain APIs `insert_before` and `insert_after` for fine
  tuning the order of middleware. [jackrg, #595]

2.6.0
-----------

- Web UI much more mobile friendly now [brandonhilkert, #573]
- Enable live polling for every section in Web UI [brandonhilkert, #567]
- Add Stats API [brandonhilkert, #565]
- Add Stats::History API [brandonhilkert, #570]
- Add Dashboard to Web UI with live and historical stat graphs [brandonhilkert, #580]
- Add option to log output to a file, reopen log file on USR2 signal [mrnugget, #581]

2.5.4
-----------

- `Sidekiq::Client.push` now accepts the worker class as a string so the
  Sidekiq client does not have to load your worker classes at all.  [#524]
- `Sidekiq::Client.push_bulk` now works with inline testing.
- **Really** fix status icon in Web UI this time.
- Add "Delete All" and "Retry All" buttons to Retries in Web UI


2.5.3
-----------

- Small Web UI fixes
- Add `delay_until` so you can delay jobs until a specific timestamp:

```ruby
Auction.delay_until(@auction.ends_at).close(@auction.id)
```

This is identical to the existing Sidekiq::Worker method, `perform_at`.

2.5.2
-----------

- Remove asset pipeline from Web UI for much faster, simpler runtime.  [#499, #490, #481]
- Add -g option so the procline better identifies a Sidekiq process, defaults to File.basename(Rails.root). [#486]

    sidekiq 2.5.1 myapp [0 of 25 busy]

- Add splay to retry time so groups of failed jobs don't fire all at once. [#483]

2.5.1
-----------

- Fix issues with core\_ext

2.5.0
-----------

- REDESIGNED WEB UI! [unity, cavneb]
- Support Honeybadger for error delivery
- Inline testing runs the client middleware before executing jobs [#465]
- Web UI can now remove jobs from queue. [#466, dleung]
- Web UI can now show the full message, not just 100 chars [#464, dleung]
- Add APIs for manipulating the retry and job queues.  See sidekiq/api. [#457]


2.4.0
-----------

- ActionMailer.delay.method now only tries to deliver if method returns a valid message.
- Logging now uses "MSG-#{Job ID}", not a random msg ID
- Allow generic Redis provider as environment variable. [#443]
- Add ability to customize sidekiq\_options with delay calls [#450]

```ruby
Foo.delay(:retry => false).bar
Foo.delay(:retry => 10).bar
Foo.delay(:timeout => 10.seconds).bar
Foo.delay_for(5.minutes, :timeout => 10.seconds).bar
```

2.3.3
-----------

- Remove option to disable Rails hooks. [#401]
- Allow delay of any module class method

2.3.2
-----------

- Fix retry.  2.3.1 accidentally disabled it.

2.3.1
-----------

- Add Sidekiq::Client.push\_bulk for bulk adding of jobs to Redis.
  My own simple test case shows pushing 10,000 jobs goes from 5 sec to 1.5 sec.
- Add support for multiple processes per host to Capistrano recipe
- Re-enable Celluloid::Actor#defer to fix stack overflow issues [#398]

2.3.0
-----------

- Upgrade Celluloid to 0.12
- Upgrade Twitter Bootstrap to 2.1.0
- Rescue more Exceptions
- Change Job ID to be Hex, rather than Base64, for HTTP safety
- Use `Airbrake#notify_or_ignore`

2.2.1
-----------

- Add support for custom tabs to Sidekiq::Web [#346]
- Change capistrano recipe to run 'quiet' before deploy:update\_code so
  it is run upon both 'deploy' and 'deploy:migrations'. [#352]
- Rescue Exception rather than StandardError to catch and log any sort
  of Processor death.

2.2.0
-----------

- Roll back Celluloid optimizations in 2.1.0 which caused instability.
- Add extension to delay any arbitrary class method to Sidekiq.
  Previously this was limited to ActiveRecord classes.

```ruby
SomeClass.delay.class_method(1, 'mike', Date.today)
```

- Sidekiq::Client now generates and returns a random, 128-bit Job ID 'jid' which
  can be used to track the processing of a Job, e.g. for calling back to a webhook
  when a job is finished.

2.1.1
-----------

- Handle networking errors causing the scheduler thread to die [#309]
- Rework exception handling to log all Processor and actor death (#325, subelsky)
- Clone arguments when calling worker so modifications are discarded. (#265, hakanensari)

2.1.0
-----------

- Tune Celluloid to no longer run message processing within a Fiber.
  This gives us a full Thread stack and also lowers Sidekiq's memory
  usage.
- Add pagination within the Web UI [#253]
- Specify which Redis driver to use: *hiredis* or *ruby* (default)
- Remove FailureJobs and UniqueJobs, which were optional middleware
  that I don't want to support in core. [#302]

2.0.3
-----------
- Fix sidekiq-web's navbar on mobile devices and windows under 980px (ezkl)
- Fix Capistrano task for first deploys [#259]
- Worker subclasses now properly inherit sidekiq\_options set in
  their superclass [#221]
- Add random jitter to scheduler to spread polls across POLL\_INTERVAL
  window. [#247]
- Sidekiq has a new mailing list: sidekiq@librelist.org  See README.

2.0.2
-----------

- Fix "Retry Now" button on individual retry page. (ezkl)

2.0.1
-----------

- Add "Clear Workers" button to UI.  If you kill -9 Sidekiq, the workers
  set can fill up with stale entries.
- Update sidekiq/testing to support new scheduled jobs API:

   ```ruby
   require 'sidekiq/testing'
   DirectWorker.perform_in(10.seconds, 1, 2)
   assert_equal 1, DirectWorker.jobs.size
   assert_in_delta 10.seconds.from_now.to_f, DirectWorker.jobs.last['at'], 0.01
   ```

2.0.0
-----------

- **SCHEDULED JOBS**!

You can now use `perform_at` and `perform_in` to schedule jobs
to run at arbitrary points in the future, like so:

```ruby
  SomeWorker.perform_in(5.days, 'bob', 13)
  SomeWorker.perform_at(5.days.from_now, 'bob', 13)
```

It also works with the delay extensions:

```ruby
  UserMailer.delay_for(5.days).send_welcome_email(user.id)
```

The time is approximately when the job will be placed on the queue;
it is not guaranteed to run at precisely at that moment in time.

This functionality is meant for one-off, arbitrary jobs.  I still
recommend `whenever` or `clockwork` if you want cron-like,
recurring jobs.  See `examples/scheduling.rb`

I want to specially thank @yabawock for his work on sidekiq-scheduler.
His extension for Sidekiq 1.x filled an obvious functional gap that I now think is
useful enough to implement in Sidekiq proper.

- Fixed issues due to Redis 3.x API changes.  Sidekiq now requires
  the Redis 3.x client.
- Inline testing now round trips arguments through JSON to catch
  serialization issues (betelgeuse)

1.2.1
-----------

- Sidekiq::Worker now has access to Sidekiq's standard logger
- Fix issue with non-StandardErrors leading to Processor exhaustion
- Fix issue with Fetcher slowing Sidekiq shutdown
- Print backtraces for all threads upon TTIN signal [#183]
- Overhaul retries Web UI with new index page and bulk operations [#184]

1.2.0
-----------

- Full or partial error backtraces can optionally be stored as part of the retry
  for display in the web UI if you aren't using an error service. [#155]

```ruby
class Worker
  include Sidekiq::Worker
  sidekiq_options :backtrace => [true || 10]
end
```
- Add timeout option to kill a worker after N seconds (blackgold9)

```ruby
class HangingWorker
  include Sidekiq::Worker
  sidekiq_options :timeout => 600
  def perform
    # will be killed if it takes longer than 10 minutes
  end
end
```

- Fix delayed extensions not available in workers [#152]
- In test environments add the `#drain` class method to workers. This method
  executes all previously queued jobs. (panthomakos)
- Sidekiq workers can be run inline during tests, just `require 'sidekiq/testing/inline'` (panthomakos)
- Queues can now be deleted from the Sidekiq web UI [#154]
- Fix unnecessary shutdown delay due to Retry Poller [#174]

1.1.4
-----------

- Add 24 hr expiry for basic keys set in Redis, to avoid any possible leaking.
- Only register workers in Redis while working, to avoid lingering
  workers [#156]
- Speed up shutdown significantly.

1.1.3
-----------

- Better network error handling when fetching jobs from Redis.
  Sidekiq will retry once per second until it can re-establish
  a connection. (ryanlecompte)
- capistrano recipe now uses `bundle_cmd` if set [#147]
- handle multi\_json API changes (sferik)

1.1.2
-----------

- Fix double restart with cap deploy [#137]

1.1.1
-----------

- Set procline for easy monitoring of Sidekiq status via "ps aux"
- Fix race condition on shutdown [#134]
- Fix hang with cap sidekiq:start [#131]

1.1.0
-----------

- The Sidekiq license has switched from GPLv3 to LGPLv3!
- Sidekiq::Client.push now returns whether the actual Redis
  operation succeeded or not. [#123]
- Remove UniqueJobs from the default middleware chain.  Its
  functionality, while useful, is unexpected for new Sidekiq
  users.  You can re-enable it with the following config.
  Read #119 for more discussion.

```ruby
Sidekiq.configure_client do |config|
  require 'sidekiq/middleware/client/unique_jobs'
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJobs
  end
end
Sidekiq.configure_server do |config|
  require 'sidekiq/middleware/server/unique_jobs'
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::UniqueJobs
  end
end
```

1.0.0
-----------

Thanks to all Sidekiq users and contributors for helping me
get to this big milestone!

- Default concurrency on client-side to 5, not 25 so we don't
  create as many unused Redis connections, same as ActiveRecord's
  default pool size.
- Ensure redis= is given a Hash or ConnectionPool.

0.11.2
-----------

- Implement "safe shutdown".  The messages for any workers that
  are still busy when we hit the TERM timeout will be requeued in
  Redis so the messages are not lost when the Sidekiq process exits.
  [#110]
- Work around Celluloid's small 4kb stack limit [#115]
- Add support for a custom Capistrano role to limit Sidekiq to
  a set of machines. [#113]

0.11.1
-----------

- Fix fetch breaking retry when used with Redis namespaces. [#109]
- Redis connection now just a plain ConnectionPool, not CP::Wrapper.
- Capistrano initial deploy fix [#106]
- Re-implemented weighted queues support (ryanlecompte)

0.11.0
-----------

- Client-side API changes, added sidekiq\_options for Sidekiq::Worker.
  As a side effect of this change, the client API works on Ruby 1.8.
  It's not officially supported but should work [#103]
- NO POLL!  Sidekiq no longer polls Redis, leading to lower network
  utilization and lower latency for message processing.
- Add --version CLI option

0.10.1
-----------

- Add details page for jobs in retry queue (jcoene)
- Display relative timestamps in web interface (jcoene)
- Capistrano fixes (hinrik, bensie)

0.10.0
-----------

- Reworked capistrano recipe to make it more fault-tolerant [#94].
- Automatic failure retry!  Sidekiq will now save failed messages
  and retry them, with an exponential backoff, over about 20 days.
  Did a message fail to process?  Just deploy a bug fix in the next
  few days and Sidekiq will retry the message eventually.

0.9.1
-----------

- Fix missed deprecations, poor method name in web UI

0.9.0
-----------

- Add -t option to configure the TERM shutdown timeout
- TERM shutdown timeout is now configurable, defaults to 5 seconds.
- USR1 signal now stops Sidekiq from accepting new work,
  capistrano sends USR1 at start of deploy and TERM at end of deploy
  giving workers the maximum amount of time to finish.
- New Sidekiq::Web rack application available
- Updated Sidekiq.redis API

0.8.0
-----------

- Remove :namespace and :server CLI options (mperham)
- Add ExceptionNotifier support (masterkain)
- Add capistrano support (mperham)
- Workers now log upon start and finish (mperham)
- Messages for terminated workers are now automatically requeued (mperham)
- Add support for Exceptional error reporting (bensie)

0.7.0
-----------

- Example chef recipe and monitrc script (jc00ke)
- Refactor global configuration into Sidekiq.configure\_server and
  Sidekiq.configure\_client blocks. (mperham)
- Add optional middleware FailureJobs which saves failed jobs to a
  'failed' queue (fbjork)
- Upon shutdown, workers are now terminated after 5 seconds.  This is to
  meet Heroku's hard limit of 10 seconds for a process to shutdown. (mperham)
- Refactor middleware API for simplicity, see sidekiq/middleware/chain. (mperham)
- Add `delay` extensions for ActionMailer and ActiveRecord. (mperham)
- Added config file support. See test/config.yml for an example file.  (jc00ke)
- Added pidfile for tools like monit (jc00ke)

0.6.0
-----------

- Resque-compatible processing stats in redis (mperham)
- Simple client testing support in sidekiq/testing (mperham)
- Plain old Ruby support via the -r cli flag (mperham)
- Refactored middleware support, introducing ability to add client-side middleware (ryanlecompte)
- Added middleware for ignoring duplicate jobs (ryanlecompte)
- Added middleware for displaying jobs in resque-web dashboard (maxjustus)
- Added redis namespacing support (maxjustus)

0.5.1
-----------

- Initial release!
