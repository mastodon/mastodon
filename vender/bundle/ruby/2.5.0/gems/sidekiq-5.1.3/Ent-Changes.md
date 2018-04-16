# Sidekiq Enterprise Changelog

[Sidekiq Changes](https://github.com/mperham/sidekiq/blob/master/Changes.md) | [Sidekiq Pro Changes](https://github.com/mperham/sidekiq/blob/master/Pro-Changes.md) | [Sidekiq Enterprise Changes](https://github.com/mperham/sidekiq/blob/master/Ent-Changes.md)

Please see [http://sidekiq.org/](http://sidekiq.org/) for more details and how to buy.

1.7.1
-------------

- Fix Lua error in concurrent rate limiter under heavy contention
- Remove superfluous `freeze` calls on Strings [#3759]

1.7.0
-------------

- **NEW FEATURE** [Rolling restarts](https://github.com/mperham/sidekiq/wiki/Ent-Rolling-Restarts) - great for long running jobs!
- Adjust middleware so unique jobs that don't push aren't registered in a Batch [#3662]
- Add new unlimited rate limiter, useful for testing [#3743]
```ruby
limiter = Sidekiq::Limiter.unlimited(...any args...)
```

1.6.1
-------------

- Fix crash in rate limiter middleware when used with custom exceptions [#3604]

1.6.0
-------------

- Show process "leader" tag on Busy page, requires Sidekiq 5.0.2 [#2867]
- Capture custom metrics with the `save_history` API. [#2815]
- Implement new `unique_until: 'start'` policy option. [#3471]

1.5.4
-------------

- Fix broken Cron page in Web UI [#3458]

1.5.3
-------------

- Remove dependency on the algorithms gem [#3446]
- Allow user to specify max memory in megabytes with SIDEKIQ\_MAXMEM\_MB [#3451]
- Implement logic to detect app startup failure, sidekiqswarm will exit
  rather than try to restart the app forever [#3450]
- Another fix for doubly-encrypted arguments [#3368]

1.5.2
-------------

- Fix encrypted arguments double-encrypted by retry or rate limiting [#3368]
- Fix leak in concurrent rate limiter, run this in Rails console to clean up existing data [#3323]
```ruby
expiry = 1.month.to_i; Sidekiq::Limiter.redis { |c| c.scan_each(match: "lmtr-cfree-*") { |key| c.expire(key, expiry) } }
```

1.5.1
-------------

- Fix issue with census startup when not using Bundler configuration for
  source credentials.

1.5.0
-------------

- Add new web authorization API [#3251]
- Update all sidekiqswarm env vars to use SIDEKIQ\_ prefix [#3218]
- Add census reporting, the leader will ping contribsys nightly with aggregate usage metrics

1.4.0
-------------

- No functional changes, require latest Sidekiq and Sidekiq Pro versions

1.3.2
-------------

- Upgrade encryption to use OpenSSL's more secure GCM mode. [#3060]

1.3.1
-------------

- Fix multi-process memory monitoring on CentOS 6.x [#3063]
- Polish the new encryption feature a bit.

1.3.0
-------------

- **BETA** [New encryption feature](https://github.com/mperham/sidekiq/wiki/Ent-Encryption)
  which automatically encrypts the last argument of a Worker, aka the secret bag.

1.2.4
-------------

- Fix issue causing some minutely jobs to execute every other minute.
- Log a warning if slow periodic processing causes us to miss a clock tick.

1.2.3
-------------

- Periodic jobs could stop executing until process restart if Redis goes down [#3047]

1.2.2
-------------

- Add API to check if a unique lock is present. See [#2932] for details.
- Tune concurrent limiters to minimize thread thrashing under heavy contention. [#2944]
- Add option for tuning which Bundler groups get preloaded with `sidekiqswarm` [#3025]
```
SIDEKIQ_PRELOAD=default,production bin/sidekiqswarm ...
# Use an empty value for maximum application compatibility
SIDEKIQ_PRELOAD= bin/sidekiqswarm ...
```

1.2.1
-------------

- Multi-Process mode can now monitor the RSS memory of children and
  restart any that grow too large.  To limit children to 1GB each:
```
MAXMEM_KB=1048576 COUNT=2 bundle exec sidekiqswarm ...
```

1.2.0
-------------

- **NEW FEATURE** Multi-process mode!  Sidekiq Enterprise can now fork multiple worker
  processes, enabling significant memory savings.  See the [wiki
documentation](https://github.com/mperham/sidekiq/wiki/Ent-Multi-Process) for details.


0.7.10
-------------

- More precise gemspec dependency versioning

1.1.0
-------------

- **NEW FEATURE** Historical queue metrics, [documented in the wiki](https://github.com/mperham/sidekiq/wiki/Ent-Historical-Metrics) [#2719]

0.7.9, 1.0.2
-------------

- Window limiters can now accept arbitrary window sizes [#2686]
- Fix race condition in window limiters leading to non-stop OverLimit [#2704]
- Fix invalid overage counts when nesting concurrent limiters

1.0.1
----------

- Fix crash in periodic subsystem when a follower shuts down, thanks
  to @justinko for reporting.

1.0.0
----------

- Enterprise 1.x targets Sidekiq 4.x.
- Rewrite several features to remove Celluloid dependency.  No
  functional changes.

0.7.8
----------

- Fix `unique_for: false` [#2658]


0.7.7
----------

- Enterprise 0.x targets Sidekiq 3.x.
- Fix racy shutdown event which could lead to disappearing periodic
  jobs, requires Sidekiq >= 3.5.3.
- Add new :leader event which is fired when a process gains leadership.

0.7.6
----------

- Redesign how overrated jobs are rescheduled to avoid creating new
  jobs. [#2619]

0.7.5
----------

- Fix dynamic creation of concurrent limiters [#2617]

0.7.4
----------
- Add additional check to prevent duplicate periodic job creation
- Allow user-specified TTLs for rate limiters [#2607]
- Paginate rate limiter index page [#2606]

0.7.3
----------

- Rework `Sidekiq::Limiter` redis handling to match global redis handling.
- Allow user to customize rate limit backoff logic and handle custom
  rate limit errors.
- Fix scalability issue with Limiter index page.

0.7.2
----------

- Fix typo which prevented limiters with '0' in their names.

0.7.1
----------

- Fix issue where unique scheduled jobs can't be enqueued upon schedule
  due to the existing unique lock. [#2499]

0.7.0
----------

Initial release.
