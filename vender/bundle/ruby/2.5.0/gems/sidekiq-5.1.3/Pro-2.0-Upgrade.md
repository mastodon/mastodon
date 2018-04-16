# Upgrading to Sidekiq Pro 2.0

Sidekiq Pro 2.0 allows nested batches for more complex job workflows
and provides a new reliable scheduler which uses Lua to guarantee
atomicity and much higher performance.

It also removes deprecated APIs, changes the batch data format and
how features are activated.  Read carefully to ensure your upgrade goes
smoothly.

Sidekiq Pro 2.0 requires Sidekiq 3.3.2 or greater.  Redis 2.8 is
recommended; Redis 2.4 or 2.6 will work but some functionality will not be
available.

**Note that you CANNOT go back to Pro 1.x once you've created batches
with 2.x.  The new batches will not process correctly with 1.x.**

**If you are on a version of Sidekiq Pro <1.5, you should upgrade to the
latest 1.x version and run it for a week before upgrading to 2.0.**

## Nested Batches

Batches can now be nested within the `jobs` method.
This feature enables Sidekiq Pro to handle workflow processing of any size
and complexity!

```ruby
a = Sidekiq::Batch.new
a.on(:success, SomeCallback)
a.jobs do
  SomeWork.perform_async

  b = Sidekiq::Batch.new
  b.on(:success, MyCallback)
  b.jobs do
    OtherWork.perform_async
  end
end
```

Parent batch callbacks are not processed until all child batch callbacks have
run successfully.  In the example above, `MyCallback` will always fire
before `SomeCallback` because `b` is considered a child of `a`.

Of course you can dynamically add child batches while a batch job is executing.

```ruby
def perform(*args)
  do_something(args)

  if more_work?
    # Sidekiq::Worker#batch returns the Batch this job is part of.
    batch.jobs do
      b = Sidekiq::Batch.new
      b.on(:success, MyCallback)
      b.jobs do
        OtherWork.perform_async
      end
    end
  end
end
```

More context: [#1485]

## Batch Data

The batch data model was overhauled.  Batch data should take
significantly less space in Redis now.  A simple benchmark shows 25%
savings but real world savings should be even greater.

* Batch 2.x BIDs are 14 character URL-safe Base64-encoded strings, e.g.
  "vTF1-9QvLPnREQ".  Batch 1.x BIDs were 16 character hex-encoded
  strings, e.g. "4a3fc67d30370edf".
* In 1.x, batch data was not removed until it naturally expired in Redis.
  In 2.x, all data for a batch is removed from Redis once the batch has
  run any success callbacks.
* Because of the former point, batch expiry is no longer a concern.
  Batch expiry is hardcoded to 30 days and is no longer user-tunable.
* Failed batch jobs no longer automatically store any associated
  backtrace in Redis.

**There's no data migration required.  Sidekiq Pro 2.0 transparently handles
both old and new format.**

More context: [#2130]

## Reliability

2.0 brings a new reliable scheduler which uses Lua inside Redis so enqueuing
scheduled jobs is atomic.  Benchmarks show it 50x faster when enqueuing
lots of jobs.

**Two caveats**:
- Client-side middleware is not executed
  for each job when enqueued with the reliable scheduler.  No Sidekiq or
  Sidekiq Pro functionality is affected by this change but some 3rd party
  plugins might be.
- The Lua script used inside the reliable scheduler is not safe for use
  with Redis Cluster or other multi-master Redis solutions.
  It is safe to use with Redis Sentinel or a typical master/slave replication setup.

**You no longer require anything to use the Reliability features.**

* Activate reliable fetch and/or the new reliable scheduler:
```ruby
Sidekiq.configure_server do |config|
  config.reliable_fetch!
  config.reliable_scheduler!
end
```
* Activate reliable push:
```ruby
Sidekiq::Client.reliable_push!
```

More context: [#2130]

## Other Changes

* You must require `sidekiq/pro/notifications` if you want to use the
  existing notification schemes.  I don't recommend using them as the
  newer-style `Sidekiq::Batch#on` method is simpler and more flexible.
* Several classes have been renamed.  Generally these classes are ones
  you should not need to require/use in your own code, e.g. the Batch
  middleware.
* You can add `attr_accessor :jid` to a Batch callback class and Sidekiq
  Pro will set it to the jid of the callback job. [#2178]
* There's now an official API to iterate all known Batches [#2191]
```ruby
Sidekiq::BatchSet.new.each {|status| p status.bid }
```
* The Web UI now shows the Sidekiq Pro version in the footer. [#1991]

## Thanks

Adam Prescott, Luke van der Hoeven and Jon Hyman all provided valuable
feedback during the release process.  Thank you guys!
