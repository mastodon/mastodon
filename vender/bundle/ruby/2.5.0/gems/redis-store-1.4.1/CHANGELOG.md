# Changelog

## 1.4.1

Breaking Changes

* None

Added

* [Support for Redis client library v4](https://github.com/redis-store/redis-store/issues/277)

Fixed

* None

## 1.4.0

Breaking Changes

* None

Added

* Pluggable backend for serializing data in/out of Redis, eventually replacing `:marshalling` in v2.

Fixed

* Conventional `Marshal.dump` usage allowing potential security vulnerability (CVE-2017-1000248) 

## 1.3.0

Breaking Changes

* None

Added

* Add support for marshalling mset

Fixed

* Set :raw => true if marshalling
* Forward new Hash, not nil, when options are unset

## 1.2.0

Breaking Changes

* None

Added

* Allow changing namespaces on the fly
* Begin testing against ruby 2.3.0

Fixed

* Use batched deletes for flushdb with a namespace
* pass set command options to redis
* bump rbx 2
* fix setex marshalling for distributed store
* changes to new url
* :warning: shadowing outer local variable - key, pattern, value
* :warning: `*' interpreted as argument prefix
* Removed duplicated method ttl

## 1.1.7

Breaking Changes

* None

Added

* Added redis_version and supports_redis_version? methods to Store and DistributedStore

Fixed

* Handle minor and patch version correctly as they may be multiple digits

*1.1.6 (July 16, 2015)*

https://github.com/redis-store/redis-store/compare/v1.1.5...v1.1.6

*1.1.5 (June 8, 2015)*

https://github.com/redis-store/redis-store/compare/v1.1.4...v1.1.5

*1.1.4 (August 20, 2013)*

  * Bump version v1.1.4
  * Release redis-rails 4.0.0
  * Release redis-actionpack 4.0.0
  * Release redis-activesupport 4.0.0
  * Release redis-sinatra 1.4.0
  * Release redis-rack-cache 1.2.2
  * Release redis-i18n 0.6.5
  * Release redis-rack 1.5.0
  * New versions of the AS, AP and Rails gems [Alexey Vasiliev]
  * fix gems for Rails 4 [Alexey Vasiliev]
  * JRuby testing, remove 1.8.7 from tests (unsupported), fix some tests [Alexey Vasiliev]
  * Change configurations for the Rails dummy app.
  * use @default_options when calling @pool.set to avoid infinite-ttl session leak, fixes #179 [Sean Walbran]
  * Test against Rails 4 not master [Rafael Mendonça França]
  * Make possible to work with rack 1.5 [Rafael Mendonça França]
  * Add support pluralization support to Redis i18n [Joachim Filip Ignacy Bartosik]
  * Fixes #189 [Fabrizio Regini]
  * fix CI script [Fabrizio Regini]
  * Redis::Factory => Redis::Store::Factory
  * Added performance warning, per #186. [Brian P O'Rourke]
  * Fix: read_multi was returning ActiveSupport::Cache::Entry instead of deserialized value [Miles D Goodings]
  * Fix: can't modify frozen String errors in Redis::Store::Marshalling [Miles D Goodings]
  * Add expire method and tests [Han Chang]
  * Run against Rails 4 and Ruby 2.0 [Steve Klabnik]
  * Clean up README files to be more clear and helpful [Matthew Beale]
  * Bundler 1.2.0 is now out, don't require the RC on the CI server
  * Relaxed the requirement for the Redis gem (>= 2.2). Updated development dependencies.
  * Ensure Redis 2.6 compat

*1.1.3 (October 6, 2012)*

  * Bump version v1.1.3
  * Invoke namespaced commands only when keys are present.

*1.1.2 (September 4, 2012)*

  * Bump version v1.1.2 [Matt Horan]
  * Override flushdb for namespaced datastore [Gregory Marcilhacy]

*1.1.1 (June 26, 2012)*

  * Bump version v1.1.1
  * README, CHANGELOG
  * Bumped redis-sinatra 1.3.3
  * Bumped redis-rack 1.4.2
  * Bumped redis-i18n 0.6.1
  * Relaxing dependencies
  * Relax requirement on redis (use >= 2.2.0)
      Because resque still depends on redis 2.x and sidekiq on redis 3.x,
      using >= 2.2.0 instead of ~> 3.0.0 allows compatibility with both. [Lukas Westermann]
  * Use default value for port, otherwise factory_test.rb:65 fails (port = 0) [Lukas Westermann]
  * Use redis 3.x [Lukas Westermann]
  * Adding examples for rails cache store config with URLs [aliix]
  * Bumped redis-rack-cache 1.2
  * Bump: [Matt Horan]
    - redis-rails 3.2.3
    - redis-actionpack 3.2.3
    - redis-activesupport 3.2.3
  * Loosen actionpack version requirement for possible Rails 3.2.3 compatibility [Filip Tepper]
  * Add Rails 3.2.2 support for redis-actionpack, redis-activesupport, redis-rails [Jack Chu]
  * Bumped redis-rack 1.4.1
  * Bumped:
    - redis-rack 1.4.0
    - redis-activesupport 3.2.1
    - redis-actionpack 3.2.1
    - redis-rails 3.2.1
  * Bump redis-sinatra 1.3.2

*1.1.0 (February 14, 2012)*

  * Bump version v1.1.0
  * Prepare stable releases
    - redis-store 1.1.0
    - redis-actionpack 3.1.3
    - redis-activesupport 3.1.3
    - redis-i18n 0.6.0
    - redis-rack-cache 1.1
    - redis-rack 1.3.5
    - redis-rails 3.1.3
    - redis-sinatra 1.3.1
  * Replace minitest-rails with mini_specunit [Matt Horan]
  * Bumped: [Matt Horan]
    - redis-actionpack 3.1.3.rc4
    - redis-activesupport 3.1.3.rc2
    - redis-i18n 0.6.0.rc2
    - redis-rack-cache 1.1.rc3
    - redis-rails 3.1.3.rc4
    - redis-sinatra 1.3.1.rc2
  * Remove redis-actionpack dependency on redis-rack-cache [Matt Horan]

*1.1.0 [rc2] (February 3, 2012)*

  * Bump version v1.1.0.rc2
  * Bumped: [Matt Horan]
    - redis-store 1.1.0.rc2
    - redis-actionpack 3.1.3.rc3
    - redis-rails 3.1.3.rc3
  * README, CHANGELOG
  * Don't clobber :redis_server if provided to ActionDispatch::Session::RedisStore [Matt Horan]
  * Support :servers option to ActionDispatch::Session::RedisStore [Matt Horan]
  * Add missing assertions [Matt Horan]
  * Integrate against a distributed Redis store [Matt Horan]
  * Remove duplicated logic for merging default Redis server with options [Matt Horan]
  * Rename ActionDispatch::Session::RedisSessionStore to RedisStore in keeping with documentation and MemCacheStore [Matt Horan]
  * Test auto-load of unloaded class [Matt Horan]
  * Replace assert_response with must_be [Matt Horan]
  * Pending upstream fix [Matt Horan]
  * Additional tests for rack-actionpack, borrowed from MemCacheStoreTest [Matt Horan]
  * Test redis-actionpack with dummy Rails application [Matt Horan]
  * Use Rack::Session::Redis API in RedisSessionStore [Matt Horan]
  * Quiet warnings [Matt Horan]
  * Remove superfluous tests [Matt Horan]
  * Cleanup Redis::Store::Ttl setnx and set tests with help from @mike-burns [Matt Horan]
  * Verify Ttl#setnx sets raw => true if expiry is provided [Matt Horan]
  * Fix redis-rack spec [Matt Horan]
  * Previous fix for double marshal just disabled expiry.  Instead, call setnx from Ttl module with :raw => true so that Marshal.dump [Matt Horan]
  * Test and fix for double marshal [Matt Horan]
  * Cleanup Redis::Store::Ttl spec [Matt Horan]
  * Fix Redis::Rack version require [Matt Horan]
  * Redis::Store::Ttl extends Redis#set with TTL support [Matt Horan]
  * Specs for Redis::Store::Ttl [Matt Horan]
  * Bumped:
    - redis-rack-cache 1.1.rc2
    - redis-actionpack 3.1.3.rc2
    - redis-rails 3.1.3.rc2
  * Ensure TTL is an integer - Rails cache returns a float when used with race_condition_ttl [Matt Williams]

*1.1.0 [rc] (December 30, 2011)*

  * Bump version v1.1.0.rc
  * Prepare RCs
  * redis-store 1.1.0.rc
  * CHANGELOG
  * Use strict dependencies.
  * READMEs and Licenses
  * redis-actionpack now depends on redis-rack-cache
  * Redis::Factory.convert_to_redis_client_options => Redis::Factory.resolve.
  * Don't use autoload
  * Make redis-rack-cache tests to pass again
  * Target Rack::Cache 1.1 for redis-rack-cache
  * Target Rack 1.4.0 for redis-rack
  * Gemspecs, dependencies and versions
  * Make redis-rails tests to pass again
  * redis-actionpack dependencies
  * redis-activesupport dependencies
  * Fix for redis-rack tests
  * Fix for redis-activesupport tests
  * Make redis-sinatra tests to pass again
  * Make redis-actionpack tests to pass again
  * Install bundler 1.1 RC on travis-ci.org [Michael Klishin]
  * Make redis-rack tests to pass again
  * Added SETEX support to Interface and Marshalling
  * Make redis-i18n tests to pass again
  * Make redis-activesupport tests to pass again
  * More tests for redis-store core
  * Redis::Factory is created with general options and not the redis_server [Julien Kirch]
  * Moved README.md
  * Split gems in subdirectories
  * Moved everything under redis-store
  * Use bundler 1.1.rc
  * Better Ruby idiom on File.expand_path
  * Moved Rake test tasks into lib/tasks/redis.tasks.rb, in order to DRY Rake
  * Testing: Use relative paths when referring to pid files
  * Autoload modules
  * Moved Rake test tasks under lib/ in order to make them accessible to all
  * Let the Redis::DistributedStore test to pass
  * Let Redis Rake tasks to work again
  * Run tests without dtach
  * Switch from RSpec to MiniTest::Unit
  * Removed all the references to Rails, Merb, Sinatra, Rack, i18n, Rack::Session and Rack::Cache
  * Gemfile is now depending on the gemspec. Removed Jewler.

*1.0.0 (September 1, 2011)*

  * Bump version v1.0.0
  * Avoid encoding issues when sending strings to Redis. [Damian Janowski]
  * Fixed a bug that caused all the users to share the same session (with a session_id of 0 or 1) [Mathieu Ravaux]
  * ActiveSupport cache stores reply to read_multi with a hash, not an array. [Matt Griffin]
  * Rack::Session && Rack::Cache store can be created with options [aligo]
  * add destroy_session [aligo]
  * compatible with rails 3.1. rely on Rack::Session::Redis stores API. [aligo]
  * Fixed Marshalling semantic

*1.0.0 [rc1] (June 5, 2011)*

  * Bump version v1.0.0.rc1
  * Re-implement the delete_entry because it s needed by the ActiveSupport::Cache [Cyril Mougel]
  * Change readme documentation for rack-cache to use single redis database with namespace support per Redis maintainers recommendation [Travis D. Warlick, Jr.]
  * Rack-Cache entity and meta store base classes should use the Redis::Factory.convert_to_redis_client_options method for DRYness and for namespace support [Travis D. Warlick, Jr.]
  * Modify #fetch for cache stores to return the yielded value instead of OK [Rune Botten]
  * Minor revisions to Readme language and organization [Jeff Casimir]
  * Re-implement the delete_entry because it s needed by the ActiveSupport::Cache implementation in Rails 3 [Cyril Mougel]
  * Refactor delete_matched [Andrei Kulakov]

*1.0.0 [beta5] (April 2, 2011)*

  * Bump version v1.0.0.beta5
  * Introducing Rails.cache.reconnect, useful for Unicorn environments. Closes #21
  * Namespaced i18n backend should strip namespace when lists available locales. Closes #62
  * how to configure Redis session store in Sinatra [Christian von Kleist]
  * gracefully handle Connection Refused errors, allows database fall-back on fetch [Michael Kintzer]
  * Sinatra's API must have changed, its registered not register. [Michael D'Auria]

*1.0.0 [beta4] (December 15, 2010)*

  * Bump version v1.0.0.beta4
  * Force Rails cache store when ActiveSupport is detected
  * Make sure to accept options when :servers isn't passed
  * Always force session store loading when using Rails
  * Make it compatible with Rails 3 sessions store [Andre Medeiros]
  * Better Rails 3 detection [Andre Medeiros]
  * Added support for password in Redis URI resolution [Jacob Gyllenstierna]
  * fix deleting values from session hash [Calvin Yu]
  * Use defensive design when build options for a store
  * ActiveSupport cache store doesn't accept any argument in Rails 2
  * Updated dependencies

*1.0.0 [beta3] (September 10, 2010)*

  * Bump version v1.0.0.beta3
  * Updated gemspec
  * Made compatible with Ruby 1.9.2
  * Made compatible with Rails 3
  * Making the redis-store rails session store compatible with Rails 2.3.9. [Aaron Gibralter]
  * Updated to v2.3.9 the development dependencies for Rails 2.x
  * Added password support
  * Set default URI string for Rack session store according to redis gem
  * Require redis:// scheme as mandatory part of URI string
  * Updated locked dependencies
  * Added namespace support for Redis::DistrubutedStore
  * Specs for Interface module
  * Moved a spec to reflect lib/ structure
  * Made specs run again with bundler-1.0.0.rc.2
  * Prepare for bundler-1.0.0.rc.1
  * Use tmp/ for Redis database dumps
  * README, gemspec
  * Lookup for scoped keys
  * Introducing I18n::Backend::Redis
  * Don't pollute Redis namespace. closes #16
  * Don't look twice for Rails module
  * Fixed loading ActionDispatch::Session issue with Rails 3
  * ActiveSupport cache now uses new Rails 3 namespace API
  * Let Rack::Cache entity store to use plain Redis client
  * CHANGELOG
  * Gemspec
  * Redis::DistributedMarshaled => Redis::DistributedStore
  * Extracted expiration logic in Redis::Ttl
  * Introducing Redis::Store and extracted marshalling logic into Redis::Marshalling
  * CHANGELOG
  * Gemspec
  * Removed superfluous specs. Documentation.
  * Made the specs pass with Ruby 1.9.2 and Rails 3
  * Made the specs pass with Ruby 1.9.2
  * Prepare specs for Ruby 1.9.2
  * Made the specs pass for Rails 3
  * Namespaced keys for ActiveSupport::Cache::RedisStore
  * Got RedisSessionStore working again with namespace
  * Delegate MarshaledClient#to_s decoration to Redis::Namespace
  * Redis::Namespace
  * Accept :namespace option when instantiate a store
  * Test against merb-1.1.0 for now
  * Updated Rake tasks for Redis installation
  * Advanced configurations for Rails in README. closes #8
  * Locked gems
  * Changed the gemspec according to the new directories structure
  * Changed directories structure, according to the ActiveSupport loading policies
  * Typo in CHANGELOG

*1.0.0 [beta2] (June 12, 2010)*

  * Bump version v1.0.0.beta2
  * Added committers names to CHANGELOG
  * Added CHANGELOG
  * Rake namespace: redis_cluster => redis:cluster
  * Fixed Rails 3 failing spec
  * Added ActiveSupport::Cache::RedisStore#read_multi
  * Enabled notifications for ActiveSupport::Cache::RedisStore
  * Moved spec
  * Use consistent Rails 3 check in session store
  * Make sure of use top-level module
  * Updated Rails 2.x development dependencies

*1.0.0 [beta1] (June 9, 2010)*

  * Bump version v1.0.0.beta1
  * Made specs pass for Ruby 1.9.1
  * Updated instructions to test against Rails 3.x
  * Updated copyright year
  * Prepare for v1.0.0.beta1
  * Use Rails v3.0.0.beta4
  * Require redis >= 2.0.0 gem in Gemfile
  * Updated instructions for Rails 2 session store
  * Added instructions for Rails 3 configuration
  * Check against Rails#version instead of Rails::VERSION::STRING
  * Added redis gem as dependency
  * Changed spec_helper.rb according to the new Rails 3 check
  * Fix the rails3 check [Bruno Michel]
  * Added bundler cleanup Rake task
  * Fixed ActiveSupport::Cache::RedisStore#fetch
  * Re-enabled redis:console Rake task
  * Don't use Rspec#have with ActiveSupport 3
  * Fixed Rails 2 regression for ActiveSupport::Cache::RedisStore#delete_matched
  * Fixed issues for ActiveSupport::Cache::RedisStore #delete_matched, #read, #rwrite
  * Rails 3 namespace
  * Use Rails edge instead of 3.0.0.beta3
  * Made the specs run again
  * Updated Gemfile development/test dependencies for rails3.
  * Updated README instructions
  * Updated test configuration files, according to redis-2.0.0-rc1 defaults
  * Made specs pass with redis-2.0.0 gem
  * Don't support the old redis-rb namespace
  * Import the whole redis-rb old Rake tasks
  * Updated redis-rb dependency

*0.3.8 [Final] (May 21, 2010)*

  * Fixed gemspec executable issue
  * Updated .gemspec
  * Version bump to 0.3.8
  * Started namespace migration for redis-2.0.0
  * Merge branch 'master' of http://github.com/akahn/redis-store
  * Fixed dependency issues. [Brian Takita]
  * Removed methopara because it require ruby 1.9.1. [Brian Takita]
  * Merge branch 'master' of http://github.com/dsander/redis-store [Brian Takita]
  * Moved RedisSessionStore to rack session directory. [Brian Takita]
  * Got RedisSessionStore working with passing specs. [Brian Takita]
  * Using modified version of RedisSessionStore (http://github.com/mattmatt/redis-session-store). Still needs testing. [Brian Takita]
  * Using redis 1.0.5. [Brian Takita]
  * Ignoring gem files and gemspecs with a prefix. [Brian Takita]
  * Added git and jeweler to dependencies. [Brian Takita]
  * Ignoring .bundle and rubymine files. [Brian Takita]
  * Added ability to add a prefix to the gem name via the GEM_PREFIX environment variable. [Brian Takita]
  * Fixed marshalling issues with the new Redis api. Fixed redis-server configurations for the latest version of redis-server. Added redis_cluster:start and redis_cluster:stop rake tasks. Spec suite passes. [Brian Takita]
  * Fixed redis deprecation warnings. [Brian Takita]
  * Using redis 1.0.4. Loading redis.tasks.rb from redis gem using Bundler. Fixed redis test configurations. [Brian Takita]
  * Supports redis 1.0.5 [Dominik Sander]
  * Add Rack::Session::Redis usage for Sinatra to README [Alexander Kahn]
  * Updated development and testing dependencies
  * Made compatible with rack-cache-0.5.2

*0.3.7 [Final] (November 15, 2009)*

  * Version bump to 0.3.7
  * Version bump to 0.3.7
  * Updated spec instructions in README
  * Jeweler generated redis-store.gemspec
  * Removed no longer used Rake tasks. Added Gemcutter support via Jeweler.
  * Typo
  * Let Rcov task run with the Redis cluster started
  * Make spec suite pass again
  * README.textile -> README.md
  * Re-enabled Merb specs
  * Added *.rdb in .gitignore
  * Run detached Redis instances for spec suite
  * Start detached Redis server for specs
  * Added Gemfile, removed rubygems dependecy for testing.
  * Added *.swp to .gitignore
  * Added jeweler rake tasks
  * Make it work in classic Sinatra apps. [Dmitriy Timokhin]
  * Updated README with new instructions about redis-rb

*0.3.6 [Final] (June 18, 2009)*

  * Prepare for v0.3.6
  * Updated README with new version
  * Changed Redis config files for specs
  * Updated README instructions
  * New filelist in gemspec
  * Fixed typo in spec
  * Don't try to unmarshal empty strings
  * Running specs according to the DEBUG env var
  * Added specs for uncovered Merb Cache API
  * Added rcov Rake task
  * Fix README
  * Fix typo in README
  * Updated README instructions
  * Removed RedisError catching
  * Declaring for now RedisError in spec_helper.rb
  * Removed unnecessary classes
  * Fix specs for DistributedMarshaledRedis
  * Fix some specs
  * Made Server#notify_observers private
  * Ensure to select the correct database after the socket connection
  * Reverted socket pooling. Ensure to always return an active socket.
  * Lowering default timeout from 10 to 0.1

*0.3.5 [Final] (May 7, 2009)*

  * Prepare for v0.3.5
  * Totally replace ezmobius-redis-rb Server implementation
  * Fixed default Server timeout to 1 second
  * Little refactoring
  * Ensure Server#active? always returns a boolean and never raise an exception
  * Made configurable connection pool timeout and size
  * Socket connection pooling
  * Updated README

*0.3.0 [Final] (May 3, 2009)*

  * Prepare for v0.3.0
  * README formatting issues
  * README formatting (again)
  * README formatting
  * Updated Rack::Session instructions for Sinatra
  * Make Rack::Session implementation working with Merb
  * Added instructions for Rack::Session
  * Expiration support for Rack::Session
  * Ensure to test Rails and Sinatra expiration implementations with both MarshaledRedis and DistrbutedMarshaledRedis
  * Expiration support for Merb::Cache
  * Use full qualified class names in specs. Minor spec fix.
  * Ported for foreword compatibility the expiration implementation from ezmobius/redis-rb
  * Little spec cleanup
  * Full support for Rack::Session
  * Extracted some logic into RedisFactory
  * Initial support for Rack::Session

*0.2.0 [Final] (April 30, 2009)*

  * Prepare for v0.2.0
  * Links in README
  * Maybe someday I will use the right formatting rules at first attempt
  * Still formatting README
  * Formatting for README
  * Updated instructions for Rack::Cache
  * Don't require any cache store if no Ruby framework is detected
  * Implemented EntityStore for Rack::Cache
  * Added REDIS constant for Rack::Cache::Metastore
  * MetaStore implementation for Rack::Cache

*0.1.0 [Final] (April 30, 2009)*

  * Prepare for v0.1.0
  * Sinatra cache support

*0.0.3 [Final] (April 30, 2009)*

  * Prepare for v0.0.3
  * Updated instructions for Merb
  * Hack for Merb cyclic dependency
  * Renaming main lib
  * Merb store #writable always returns true. Added pending test.
  * Merb store #fetch refactoring
  * Updated Redis installation instructions
  * Implemented #fetch for Merb store
  * Implemented #exists?, #delete and #delete_all for Merb cache store
  * Renamed project name in Rakefile
  * Updated project name in README
  * Updated README with Merb instructions
  * Changed name in gemspec
  * New gemspec
  * Initial cache store support for Merb
  * Moving files around
  * Don't complain about missing db in tmp/

*0.0.2 [Final] (April 16, 2009)*

  * Prepare for v0.0.2
  * Updated file list in gemspec
  * Updated README instructions
  * Re-enabled spec for RedisStore#fetch
  * Update rdoc
  * Fix RedisStore#clear when use a cluster
  * Test RedisStore both with single server and with a cluster
  * Fix port in DistributedMarshaledRedis spec
  * Don't slave Redis cluster node
  * Changed Redis cluster configuration
  * Added configuration for Redis cluster
  * Use a distributed system if the store uses more than one server
  * Accept params for client connection

*0.0.1 [Final] (April 11, 2009)*

  * Added :unless_exist option to #write
  * Added failing specs for :expires_in option
  * Made optional args compatible with the Cache interface
  * Implemented #delete_matched, #clear, #stats
  * Implemented #delete, #exist?, #increment, #decrement
  * Introduced RedisStore
  * Initial import
