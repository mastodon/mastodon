redis-namespace
===============

Redis::Namespace provides an interface to a namespaced subset of your [redis][] keyspace (e.g., keys with a common beginning), and requires the [redis-rb][] gem.

~~~ irb
require 'redis-namespace'
# => true

redis_connection = Redis.new
# => #<Redis client v3.1.0 for redis://127.0.0.1:6379/0>
namespaced_redis = Redis::Namespace.new(:ns, :redis => redis_connection)
# => #<Redis::Namespace v1.5.0 with client v3.1.0 for redis://127.0.0.1:6379/0/ns>

namespaced_redis.set('foo', 'bar') # redis_connection.set('ns:foo', 'bar')
# => "OK"

# Redis::Namespace automatically prepended our namespace to the key
# before sending it to our redis client.

namespaced_redis.get('foo')
# => "bar"
redis_connection.get('ns:foo')
# => "bar"

namespaced_redis.del('foo')
# => 1
namespaced_redis.get('foo')
# => nil
redis_connection.get('ns:foo')
# => nil
~~~

Installation
============

Redis::Namespace is packaged as the redis-namespace gem, and hosted on rubygems.org.

From the command line:

    $ gem install redis-namespace

Or in your Gemfile:

~~~ ruby
gem 'redis-namespace'
~~~

Caveats
=======

`Redis::Namespace` provides a namespaced interface to `Redis` by keeping an internal registry of the method signatures in `Redis` provided by the redis-rb gem;
we keep track of which arguments need the namespace added, and which return values need the namespace removed.

Blind Passthrough
-----------------
If your version of this gem doesn't know about a particular command, it can't namespace it.
Historically, this has meant that Redis::Namespace blindly passes unknown commands on to the underlying redis connection without modification which can lead to surprising effects.

As of v1.5.0, blind passthrough has been deprecated, and the functionality will be removed entirely in 2.0.

If you come across a command that is not yet supported, please open an issue on the [issue tracker][] or submit a pull-request.

Administrative Commands
-----------------------
The effects of some redis commands cannot be limited to a particular namespace (e.g., `FLUSHALL`, which literally truncates all databases in your redis server, regardless of keyspace).
Historically, this has meant that Redis::Namespace intentionally passes administrative commands on to the underlying redis connection without modification, which can lead to surprising effects.

As of v1.6.0, the direct use of administrative commands has been deprecated, and the functionality will be removed entirely in 2.0;
while such commands are often useful for testing or administration, their meaning is inherently hidden when placed behind an interface that implies it will namespace everything.

The prefered way to send an administrative command is on the redis connection
itself, which is publicly exposed as `Redis::Namespace#redis`:

~~~ ruby
namespaced.redis.flushall()
# => "OK"
~~~

2.x Planned Breaking Changes
============================

As mentioned above, 2.0 will remove blind passthrough and the administrative command passthrough.
By default in 1.5+, deprecation warnings are present and enabled;
they can be silenced by initializing `Redis::Namespace` with `warnings: false` or by setting the `REDIS_NAMESPACE_QUIET` environment variable.

Early opt-in
------------

To enable testing against the 2.x interface before its release, in addition to deprecation warnings, early opt-in to these changes can be enabled by initializing `Redis::Namespace` with `deprecations: true` or by setting the `REDIS_NAMESPACE_DEPRECATIONS` environment variable.
This should only be done once all warnings have been addressed.

Authors
=======

While there are many authors who have contributed to this project, the following have done so on an ongoing basis with at least 5 commits:

 - Chris Wanstrath (@defunkt)
 - Ryan Biesemeyer (@yaauie)
 - Steve Klabnik (@steveklabnik)
 - Terence Lee (@hone)
 - Eoin Coffey (@ecoffey)

[redis]: http://redis.io
[redis-rb]: https://github.com/redis/redis-rb
[issue tracker]: https://github.com/resque/redis-namespace/issues
