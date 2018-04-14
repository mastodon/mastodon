# Sidekiq Pro Changelog

[Sidekiq Changes](https://github.com/mperham/sidekiq/blob/master/Changes.md) | [Sidekiq Pro Changes](https://github.com/mperham/sidekiq/blob/master/Pro-Changes.md) | [Sidekiq Enterprise Changes](https://github.com/mperham/sidekiq/blob/master/Ent-Changes.md)

Please see [http://sidekiq.org/](http://sidekiq.org/) for more details and how to buy.

4.0.2
---------

- Remove super\_fetch edge case leading to an unnecessary `sleep(1)`
  call and resulting latency [#3790]
- Fix possible bad statsd metric call on super\_fetch startup
- Remove superfluous `freeze` calls on Strings [#3759]

4.0.1
---------

- Fix incompatibility with the statsd-ruby gem [#3740]

4.0.0
---------

- See the [Sidekiq Pro 4.0](Pro-4.0-Upgrade.md) release notes.


3.7.1
---------

- Deprecate timed\_fetch.  Switch to super\_fetch:
```ruby
config.super_fetch!
```


3.7.0
---------

- Refactor batch job success/failure to gracefully handle several edge
  cases with regard to Sidekiq::Shutdown.  This should greatly reduce
  the chances of seeing the long-standing "negative pending count" problem. [#3710]


3.6.1
---------

- Add support for Datadog::Statsd, it is the recommended Statsd client.  [#3699]
```ruby
Sidekiq::Pro.dogstatsd = ->{ Datadog::Statsd.new("metrics.example.com", 8125) }
```
- Size the statsd connection pool based on Sidekiq's concurrency [#3700]


3.6.0
---------

This release overhauls the Statsd metrics support and adds more
metrics for tracking Pro feature usage.  In your initializer:
```ruby
Sidekiq::Pro.statsd = ->{ ::Statsd.new("127.0.0.1", 8125) }
```
Sidekiq Pro will emit more metrics to Statsd:
```
jobs.expired - when a job is expired
jobs.recovered.push - when a job is recovered by reliable_push after network outage
jobs.recovered.fetch - when a job is recovered by super_fetch after process crash
batch.created - when a batch is created
batch.complete - when a batch is completed
batch.success - when a batch is successful
```
Sidekiq Pro's existing Statsd middleware has been rewritten to leverage the new API.
Everything should be backwards compatible with one deprecation notice.


3.5.4
---------

- Fix case in SuperFetch where Redis downtime can lead to processor thread death [#3684]
- Fix case where TimedFetch might not recover some pending jobs
- Fix edge case in Batch::Status#poll leading to premature completion [#3640]
- Adjust scan API to check 100 elements at a time, to minimize network round trips
  when scanning large sets.

3.5.3
---------

- Restore error check for super\_fetch's job ack [#3601]
- Trim error messages saved in Batch's failure hash, preventing huge
  messages from bloating Redis. [#3570]

3.5.2
---------

- Fix `Status#completed?` when run against a Batch that had succeeded
  and was deleted. [#3519]

3.5.1
---------

- Work with Sidekiq 5.0.2+
- Improve performance of super\_fetch with weighted queues [#3489]

3.5.0
---------

- Add queue pause/unpause endpoints for scripting via curl [#3445]
- Change how super\_fetch names private queues to avoid hostname/queue clashes. [#3443]
- Re-implement `Sidekiq::Queue#delete_job` to avoid O(n) runtime [#3408]
- Batch page displays Pending JIDs if less than 10 [#3130]
- Batch page has a Search button to find associated Retries [#3130]
- Make Batch UI progress bar more friendly to the colorblind [#3387]

3.4.5
---------

- Fix potential job loss with reliable scheduler when lots of jobs are scheduled
  at precisely the same time. Thanks to raivil for his hard work in
  reproducing the bug. [#3371]

3.4.4
---------

- Optimize super\_fetch shutdown to restart jobs quicker [#3249]

3.4.3
---------

- Limit reliable scheduler to enqueue up to 100 jobs per call, minimizing Redis latency [#3332]
- Fix bug in super\_fetch logic for queues with `_` in the name [#3339]

3.4.2
---------

- Add `Batch::Status#invalidated?` API which returns true if any/all
  JIDs were invalidated within the batch. [#3326]

3.4.1
---------

- Allow super\_fetch's orphan job check to happen as often as every hour [#3273]
- Officially deprecate reliable\_fetch algorithm, I now recommend you use `super_fetch` instead:
```ruby
Sidekiq.configure_server do |config|
  config.super_fetch!
end
```
Also note that Sidekiq's `-i/--index` option is no longer used/relevant with super\_fetch.
- Don't display "Delete/Retry All" buttons when filtering in Web UI [#3243]
- Reimplement Sidekiq::JobSet#find\_job with ZSCAN [#3197]

3.4.0
---------

- Introducing the newest reliable fetching algorithm: `super_fetch`!  This
  algorithm will replace reliable\_fetch in Pro 4.0.  super\_fetch is
  bullet-proof across all environments, no longer requiring stable
  hostnames or an index to be set per-process. [#3077]
```ruby
Sidekiq.configure_server do |config|
  config.super_fetch!
end
```
  Thank you to @jonhyman for code review and the Sidekiq Pro customers that
  beta tested super\_fetch.

3.3.3
---------

- Update Web UI extension to work with Sidekiq 4.2.0's new Web UI. [#3075]

3.3.2
---------

- Minimize batch memory usage after success [#3083]
- Extract batch's 24 hr linger expiry to a LINGER constant so it can be tuned. [#3011]

3.3.1
---------

- If environment is unset, treat it as development so reliable\_fetch works as before 3.2.2.

3.3.0
---------

- Don't delete batches immediately upon success but set a 24 hr expiry, this allows
  Sidekiq::Batch::Status#poll to work, even after batch success. [#3011]
- New `Sidekiq::PendingSet#destroy(jid)` API to remove poison pill jobs [#3015]

3.2.2
---------

- A default value for -i is only set in development now, staging or
  other environments must set an index if you wish to use reliable\_fetch. [#2971]
- Fix nil dereference when checking for jobs over timeout in timed\_fetch


3.2.1
---------

- timed\_fetch now works with namespaces.  [ryansch]


3.2.0
---------

- Fixed detection of missing batches, `NoSuchBatch` should be raised
  properly now if `Sidekiq::Batch.new(bid)` is called on a batch no
  longer in Redis.
- Remove support for Pro 1.x format batches.  This version will no
  longer seamlessly process batches created with Sidekiq Pro 1.x.
  As always, upgrade one major version at a time to ensure a smooth
  transition.
- Fix edge case where a parent batch could expire before a child batch
  was finished processing, leading to missing batches [#2889]

2.1.5
---------

- Fix edge case where a parent batch could expire before a child batch
  was finished processing, leading to missing batches [#2889]

3.1.0
---------

- New container-friendly fetch algorithm: `timed_fetch`.  See the
  [wiki documentation](https://github.com/mperham/sidekiq/wiki/Pro-Reliability-Server)
  for trade offs between the two reliability options.  You should
  use this if you are on Heroku, Docker, Amazon ECS or EBS or
  another container-based system.


3.0.6
---------

- Fix race condition on reliable fetch shutdown

3.0.5
---------

- Statsd metrics now account for ActiveJob class names
- Allow reliable fetch internals to be overridden [jonhyman]

3.0.4
---------

- Queue pausing no longer requires reliable fetch. [#2786]

3.0.3, 2.1.4
------------

- Convert Lua-based `Sidekiq::Queue#delete_by_class` to Ruby-based, to
  avoid O(N^2) performance and possible Redis failure. [#2806]

3.0.2
-----------

- Make job registration with batch part of the atomic push so batch
  metadata can't get out of sync with the job data. [#2714]

3.0.1
-----------

- Remove a number of Redis version checks since we can assume 2.8+ now.
- Fix expiring jobs client middleware not loaded on server

3.0.0
-----------

- See the [Pro 3.0 release notes](Pro-3.0-Upgrade.md).

2.1.3
-----------

- Don't enable strict priority if using weighted queueing like `-q a,1 -q b,1`
- Safer JSON mangling in Lua [#2639]

2.1.2
-----------

- Lock Sidekiq Pro 2.x to Sidekiq 3.x.

2.1.1
-----------

- Make ShardSet lazier so Redis can first be initialized at startup. [#2603]


2.1.0
-----------

- Explicit support for sharding batches.  You list your Redis shards and
  Sidekiq Pro will randomly spread batches across the shards.  The BID
  will indicate which shard contains the batch data.  Jobs within a
  batch may be spread across all shards too. [#2548, jonhyman]
- Officially deprecate Sidekiq::Notifications code.  Notifications have
  been undocumented for months now. [#2575]


2.0.8
-----------

- Fix reliable scheduler mangling large numeric arguments.  Lua's CJSON
  library cannot accurately encode numbers larger than 14 digits! [#2478]

2.0.7
-----------

- Optimize delete of enormous batches (100,000s of jobs) [#2458]

2.0.6, 1.9.3
--------------

- CSRF protection in Sidekiq 3.4.2 broke job filtering in the Web UI [#2442]
- Sidekiq Pro 1.x is now limited to Sidekiq < 3.5.0.

2.0.5
-----------

- Atomic scheduler now sets `enqueued_at` [#2414]
- Batches now account for jobs which are stopped by client middleware [#2406]
- Ignore redundant calls to `Sidekiq::Client.reliable_push!` [#2408]

2.0.4
-----------

- Reliable push now supports sharding [#2409]
- Reliable push now only catches Redis exceptions [#2307]

2.0.3
-----------

- Display Batch callback data on the Batch details page. [#2347]
- Fix incompatibility with Pro Web and Rack middleware. [#2344] Thank
  you to Jason Clark for the tip on how to fix it.

2.0.2
-----------

- Multiple Web UIs can now run in the same process. [#2267] If you have
  multiple Redis shards, you can mount UIs for all in the same process:
```ruby
POOL1 = ConnectionPool.new { Redis.new(:url => "redis://localhost:6379/0") }
POOL2 = ConnectionPool.new { Redis.new(:url => "redis://localhost:6378/0") }

mount Sidekiq::Pro::Web => '/sidekiq' # default
mount Sidekiq::Pro::Web.with(redis_pool: POOL1), at: '/sidekiq1', as: 'sidekiq1' # shard1
mount Sidekiq::Pro::Web.with(redis_pool: POOL2), at: '/sidekiq2', as: 'sidekiq2' # shard2
```
- **SECURITY** Fix batch XSS in error data.  Thanks to moneybird.com for
  reporting the issue.

2.0.1
-----------

- Add `batch.callback_queue` so batch callbacks can use a higher
  priority queue than jobs. [#2200]
- Gracefully recover if someone runs `SCRIPT FLUSH` on Redis. [#2240]
- Ignore errors when attempting `bulk_requeue`, allowing clean shutdown

2.0.0
-----------

- See [the Upgrade Notes](Pro-2.0-Upgrade.md) for detailed notes.

1.9.2
-----------

- As of 1/1/2015, Sidekiq Pro is hosted on a new dedicated server.
  Happy new year and let's hope for 100% uptime!
- Fix bug in reliable\_fetch where jobs could be duplicated if a Sidekiq
  process crashed and you were using weighted queues. [#2120]

1.9.1
-----------

- **SECURITY** Fix XSS in batch description, thanks to intercom.io for reporting the
  issue.  If you don't use batch descriptions, you don't need the fix.

1.9.0
-----------

- Add new expiring jobs feature [#1982]
- Show batch expiration on Batch details page [#1981]
- Add '$' batch success token to the pubsub support. [#1953]


1.8.0
-----------

- Fix race condition where Batches can complete
  before they have been fully defined or only half-defined. Requires
  Sidekiq 3.2.3. [#1919]


1.7.6
-----------

- Quick release to verify #1919


1.7.5
-----------

- Fix job filtering within the Dead tab.
- Add APIs and wiki documentation for invalidating jobs within a batch.


1.7.4
-----------

- Awesome ANSI art startup banner!


1.7.3
-----------

- Batch callbacks should use the same queue as the associated jobs.

1.7.2
-----------

- **DEPRECATION** Use `Batch#on(:complete)` instead of `Batch#notify`.
  The specific Campfire, HipChat, email and other notification schemes
  will be removed in 2.0.0.
- Remove batch from UI when successful. [#1745]
- Convert batch callbacks to be asynchronous jobs for error handling [#1744]

1.7.1
-----------

- Fix for paused queues being processed for a few seconds when starting
  a new Sidekiq process.
- Add a 5 sec delay when starting reliable fetch on Heroku to minimize
  any duplicate job processing with another process shutting down.

1.7.0
-----------

- Add ability to pause reliable queues via API.
```ruby
q = Sidekiq::Queue.new("critical")
q.pause!
q.paused? # => true
q.unpause!
```

Sidekiq polls Redis every 10 seconds for paused queues so pausing will take
a few seconds to take effect.

1.6.0
-----------

- Compatible with Sidekiq 3.

1.5.1
-----------

- Due to a breaking API change in Sidekiq 3.0, this version is limited
  to Sidekiq 2.x.

1.5.0
-----------

- Fix issue on Heroku where reliable fetch could orphan jobs [#1573]


1.4.3
-----------

- Reverse sorting of Batches in Web UI [#1098]
- Refactoring for Sidekiq 3.0, Pro now requires Sidekiq 2.17.5

1.4.2
-----------

- Tolerate expired Batches in the web UI.
- Fix 100% CPU usage when using weighted queues and reliable fetch.

1.4.1
-----------

- Add batch progress bar to batch detail page. [#1398]
- Fix race condition in initializing Lua scripts


1.4.0
-----------

- Default batch expiration has been extended to 3 days, from 1 day previously.
- Batches now sort in the Web UI according to expiry time, not creation time.
- Add user-configurable batch expiry.  If your batches might take longer
  than 72 hours to process, you can extend the expiration date.

```ruby
b = Sidekiq::Batch.new
b.expires_in 5.days
...
```

1.3.2
-----------

- Lazy load Lua scripts so a Redis connection is not required on bootup.

1.3.1
-----------

- Fix a gemspec packaging issue which broke the Batch UI.

1.3.0
-----------

Thanks to @jonhyman for his contributions to this Sidekiq Pro release.

This release includes new functionality based on the SCAN command newly
added to Redis 2.8.  Pro still works with Redis 2.4 but some
functionality will be unavailable.

- Job Filtering in the Web UI!
  You can now filter retries and scheduled jobs in the Web UI so you
  only see the jobs relevant to your needs.  Queues cannot be filtered;
  Redis does not provide the same SCAN operation on the LIST type.
  **Redis 2.8**
  ![Filtering](https://f.cloud.github.com/assets/2911/1619465/f47529f2-5657-11e3-8cd1-33899eb72aad.png)
- SCAN support in the Sidekiq::SortedSet API.  Here's an example that
  finds all jobs which contain the substring "Warehouse::OrderShip"
  and deletes all matching retries.  If the set is large, this API
  will be **MUCH** faster than standard iteration using each.
  **Redis 2.8**
```ruby
  Sidekiq::RetrySet.new.scan("Warehouse::OrderShip") do |job|
    job.delete
  end
```

- Sidekiq::Batch#jobs now returns the set of JIDs added to the batch.
- Sidekiq::Batch#jids returns the complete set of JIDs associated with the batch.
- Sidekiq::Batch#remove\_jobs(jid, jid, ...) removes JIDs from the set, allowing early termination of jobs if they become irrelevant according to application logic.
- Sidekiq::Batch#include?(jid) allows jobs to check if they are still
  relevant to a Batch and exit early if not.
- Sidekiq::SortedSet#find\_job(jid) now uses server-side Lua if possible **Redis 2.6** [jonhyman]
- The statsd integration now sets global job counts:
```ruby
  jobs.count
  jobs.success
  jobs.failure
```

- Change shutdown logic to push leftover jobs in the private queue back
  into the public queue when shutting down with Reliable Fetch.  This
  allows the safe decommission of a Sidekiq Pro process when autoscaling. [jonhyman]
- Add support for weighted random fetching with Reliable Fetch [jonhyman]
- Pro now requires Sidekiq 2.17.0

1.2.5
-----------

- Convert Batch UI to use Sidekiq 2.16's support for extension localization.
- Update reliable\_push to work with Sidekiq::Client refactoring in 2.16
- Pro now requires Sidekiq 2.16.0

1.2.4
-----------

- Convert Batch UI to Bootstrap 3
- Pro now requires Sidekiq 2.15.0
- Add Sidekiq::Batch::Status#delete [#1205]

1.2.3
-----------

- Pro now requires Sidekiq 2.14.0
- Fix bad exception handling in batch callbacks [#1134]
- Convert Batch UI to ERB

1.2.2
-----------

- Problem with reliable fetch which could lead to lost jobs when Sidekiq
  is shut down normally.  Thanks to MikaelAmborn for the report. [#1109]

1.2.1
-----------

- Forgot to push paging code necessary for `delete_job` performance.

1.2.0
-----------

- **LEAK** Fix batch key which didn't expire in Redis.  Keys match
  /b-[a-f0-9]{16}-pending/, e.g. "b-4f55163ddba10aa0-pending" [#1057]
- **Reliable fetch now supports multiple queues**, using the algorithm spec'd
  by @jackrg [#1102]
- Fix issue with reliable\_push where it didn't return the JID for a pushed
  job when sending previously cached jobs to Redis.
- Add fast Sidekiq::Queue#delete\_job(jid) API which leverages Lua so job lookup is
  100% server-side.  Benchmark vs Sidekiq's Job#delete API. **Redis 2.6**

```
Sidekiq Pro API
  0.030000   0.020000   0.050000 (  1.640659)
Sidekiq API
 17.250000   2.220000  19.470000 ( 22.193300)
```

- Add fast Sidekiq::Queue#delete\_by\_class(klass) API to remove all
  jobs of a given type.  Uses server-side Lua for performance. **Redis 2.6**

1.1.0
-----------

- New `sidekiq/pro/reliable_push` which makes Sidekiq::Client resiliant
  to Redis network failures. [#793]
- Move `sidekiq/reliable_fetch` to `sidekiq/pro/reliable_fetch`


1.0.0
-----------

- Sidekiq Pro changelog moved to mperham/sidekiq for public visibility.
- Add new Rack endpoint for easy polling of batch status via JavaScript.  See `sidekiq/rack/batch_status`

0.9.3
-----------

- Fix bad /batches path in Web UI
- Fix Sinatra conflict with sidekiq-failures

0.9.2
-----------

- Fix issue with lifecycle notifications not firing.

0.9.1
-----------

- Update due to Sidekiq API changes.

0.9.0
-----------

- Rearchitect Sidekiq's Fetch code to support different fetch
strategies.  Add a ReliableFetch strategy which works with Redis'
RPOPLPUSH to ensure we don't lose messages, even when the Sidekiq
process crashes unexpectedly. [mperham/sidekiq#607]

0.8.2
-----------

- Reimplement existing notifications using batch on_complete events.

0.8.1
-----------

- Rejigger batch callback notifications.


0.8.0
-----------

- Add new Batch 'callback' notification support, for in-process
  notification.
- Symbolize option keys passed to Pony [mperham/sidekiq#603]
- Batch no longer requires the Web UI since Web UI usage is optional.
  You must require is manually in your Web process:

```ruby
require 'sidekiq/web'
require 'sidekiq/batch/web'
mount Sidekiq::Web => '/sidekiq'
```


0.7.1
-----------

- Worker instances can access the associated jid and bid via simple
  accessors.
- Batches can now be modified while being processed so, e.g. a batch
  job can add additional jobs to its own batch.

```ruby
def perform(...)
  batch = Sidekiq::Batch.new(bid) # instantiate batch associated with this job
  batch.jobs do
    SomeWorker.perform_async # add another job
  end
end
```

- Save error backtraces in batch's failure info for display in Web UI.
- Clean up email notification a bit.


0.7.0
-----------

- Add optional batch description
- Mutable batches.  Batches can now be modified to add additional jobs
  at runtime.  Example would be a batch job which needs to create more
  jobs based on the data it is processing.

```ruby
batch = Sidekiq::Batch.new(bid)
batch.jobs do
  # define more jobs here
end
```
- Fix issues with symbols vs strings in option hashes


0.6.1
-----------

- Webhook notification support


0.6
-----------

- Redis pubsub
- Email polish


0.5
-----------

- Batches
- Notifications
- Statsd middleware
