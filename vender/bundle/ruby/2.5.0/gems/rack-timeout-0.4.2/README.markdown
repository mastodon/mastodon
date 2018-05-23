Rack::Timeout
=============

Abort requests that are taking too long; an exception is raised.

A generous timeout of 15s is the default. It's recommended to set the timeout as low as realistically viable for your application. Most applications will do fine with a setting between 2 and 5 seconds.

There's a handful of other settings, read on for details.

Rack::Timeout is not a solution to the problem of long-running requests, it's a debug and remediation tool. App developers should track rack-timeout's data and address recurring instances of particular timeouts, for example by refactoring code so it runs faster or offsetting lengthy work to happen asynchronously.


Basic Usage
-----------

The following covers currently supported versions of Rails, Rack, Ruby, and Bundler. See the Compatibility section at the end for legacy versions.

### Rails apps

```ruby
# Gemfile
gem "rack-timeout"
```

That'll load rack-timeout and set it up as a Rails middleware using the default timeout of 15s. The middleware is not inserted for the test environment.

To use a custom timeout, create an initializer file:

```ruby
# config/initializers/rack_timeout.rb
Rack::Timeout.service_timeout = 5  # seconds
```

### Rails apps, manually

You'll need to do this if you removed `Rack::Runtime` from the middleware stack, or if you want to determine yourself where in the stack `Rack::Timeout` gets inserted.

```ruby
# Gemfile
gem "rack-timeout", require:"rack/timeout/base"
```

```ruby
# config/initializers/rack_timeout.rb

# insert middleware wherever you want in the stack, optionally pass initialization arguments
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 5
```

### Sinatra and other Rack apps

```ruby
# config.ru
require "rack-timeout"

# Call as early as possible so rack-timeout runs before all other middleware.
# Setting service_timeout is recommended. If omitted, defaults to 15 seconds.
use Rack::Timeout, service_timeout: 5
```


The Rabbit Hole
---------------

Rack::Timeout takes the following settings, shown here with their default values:

```
service_timeout:   15
wait_timeout:      30
wait_overtime:     60
service_past_wait: false
```

As shown earlier, these settings can be overriden during middleware initialization:

```ruby
use Rack::Timeout, service_timeout: 5, wait_timeout: false
```

For legacy reasons, it's also possible to set these at the class level (e.g. `Rack::Timeout.service_timeout = 3`). This is, however, not recommended. Also beware this style takes precedence over all instances' initialization settings.


### Service Timeout

`service_timeout` is our most important setting.

*Service time* is the time taken from when a request first enters rack to when its response is sent back. When the application takes longer than `service_timeout` to process a request, the request's status is logged as `timed_out` and `Rack::Timeout::RequestTimeoutException` or `Rack::Timeout::RequestTimeoutError` is raised on the application thread. This may be automatically caught by the framework or plugins, so beware. Also, the exception is not guaranteed to be raised in a timely fashion, see section below about IO blocks.

Service timeout can be disabled entirely by setting the property to `0` or `false`, at which point the request skips Rack::Timeout's machinery (so no logging will be present).


### Wait Timeout

Before a request reaches the rack application, it may have spent some time being received by the web server, or waiting in the application server's queue before being dispatched to rack. The time between when a request is received by the web server and when rack starts handling it is called the *wait time*.

On Heroku, a request will be dropped when the routing layer sees no data being transferred for over 30 seconds. (You can read more about the specifics of Heroku routing's timeout [here][heroku-routing] and [here][heroku-timeout].) In this case, it makes no sense to process a request that reaches the application after having waited more than 30 seconds. That's where the `wait_timeout` setting comes in. When a request has a wait time greater than `wait_timeout`, it'll be dropped without ever being sent down to the application, and a `Rack::Timeout::RequestExpiryError` is raised. Such requests are logged as `expired`.

[heroku-routing]: https://devcenter.heroku.com/articles/http-routing#timeouts
[heroku-timeout]: https://devcenter.heroku.com/articles/request-timeout

`wait_timeout` is set at a default of 30 seconds, matching Heroku's router's timeout.

Wait timeout can be disabled entirely by setting the property to `0` or `false`.

A request's computed wait time may affect the service timeout used for it. Basically, a request's wait time plus service time may not exceed the wait timeout. The reasoning for that is based on Heroku router's behavior, that the request would be dropped anyway after the wait timeout. So, for example, with the default settings of `service_timeout=15`, `wait_timeout=30`, a request that had 20 seconds of wait time will not have a service timeout of 15, but instead of 10, as there are only 10 seconds left before `wait_timeout` is reached. This behavior can be disabled by setting `service_past_wait` to `true`. When set, the `service_timeout` setting will always be honored.

The way we're able to infer a request's start time, and from that its wait time, is through the availability of the `X-Request-Start` HTTP header, which is expected to contain the time since epoch in milliseconds. (A concession is made for nginx's sec.msec notation.)

If the `X-Request-Start` header is not present `wait_timeout` handling is skipped entirely.


### Wait Overtime

Relying on `X-Request-Start` is less than ideal, as it computes the time since the request *started* being received by the web server, rather than the time the request *finished* being received by the web server. That poses a problem for lengthy requests.

Lengthy requests are requests with a body, such as POST requests. These take time to complete being received by the application server, especially when the client has a slow upload speed, as is common for example with mobile clients or asymmetric connections.

While we can infer the time since a request started being received, we can't tell when it completed being received, which would be preferable. We're also unable to tell the time since the last byte was sent in the request, which would be relevant in tracking Heroku's router timeout appropriately.

A request that took longer than 30s to be fully received, but that had been uploading data all that while, would be dropped immediately by Rack::Timeout because it'd be considered too old. Heroku's router, however, would not have dropped this request because data was being transmitted all along.

As a concession to these shortcomings, for requests that have a body present, we allow some additional wait time on top of `wait_timeout`. This aims to make up for time lost to long uploads.

This extra time is called *wait overtime* and can be set via `wait_overtime`. It defaults to 60 seconds. This can be disabled as usual by setting the property to `0` or `false`. When disabled, there's no overtime. If you want lengthy requests to never get expired, set `wait_overtime` to a very high number.

Keep in mind that Heroku [recommends][uploads] uploading large files directly to S3, so as to prevent the dyno from being blocked for too long and hence unable to handle further incoming requests.

[uploads]: https://devcenter.heroku.com/articles/s3#file-uploads


### Timing Out During IO Blocks

Sometimes a request is taking too long to complete because it's blocked waiting on synchronous IO. Such IO does not need to be file operations, it could be, say, network or database operations. If said IO is happening in a C library that's unaware of ruby's interrupt system (i.e. anything written without ruby in mind), calling `Thread#raise` (that's what rack-timeout uses) will not have effect until after the IO block is gone.

At the moment rack-timeout does not try to address this issue. As a fail-safe against these cases, a blunter solution that kills the entire process is recommended, such as unicorn's timeouts.

More detailed explanations of the issues surrounding timing out in ruby during IO blocks can be found at:

- http://redgetan.cc/understanding-timeouts-in-cruby/
- https://shellycloud.com/blog/2013/06/the-pesky-problem-of-freezing-thin


### Timing Out Inherently Unsafe

Raising mid-flight in stateful applications is inherently unsafe. A request can be aborted at any moment in the code flow, and the application can be left in an inconsistent state. There's little way rack-timeout could be aware of ongoing state changes. Applications that rely on a set of globals (like class variables) or any other state that lives beyond a single request may find those left in an unexpected/inconsistent state after an aborted request. Some cleanup code might not have run, or only half of a set of related changes may have been applied.

A lot more can go wrong. An intricate explanation of the issue by JRuby's Charles Nutter can be found [here][broken-timeout].

Ruby 2.1 provides a way to defer the result of raising exceptions through the [Thread.handle_interrupt][handle-interrupt] method. This could be used in critical areas of your application code to prevent Rack::Timeout from accidentally wreaking havoc by raising just in the wrong moment. That said, `handle_interrupt` and threads in general are hard to reason about, and detecting all cases where it would be needed in an application is a tall order, and the added code complexity is probably not worth the trouble.

Your time is better spent ensuring requests run fast and don't need to timeout.

That said, it's something to be aware of, and may explain some eerie wonkiness seen in logs.

[broken-timeout]: http://headius.blogspot.de/2008/02/rubys-threadraise-threadkill-timeoutrb.html
[handle-interrupt]: http://www.ruby-doc.org/core-2.1.3/Thread.html#method-c-handle_interrupt


### Time Out Early and Often

Because of the aforementioned issues, it's recommended you set library-specific timeouts and leave Rack::Timeout as a last resort measure. Library timeouts will generally take care of IO issues and abort the operation safely. See [The Ultimate Guide to Ruby Timeouts][ruby-timeouts].

You'll want to set all relevant timeouts to something lower than Rack::Timeout's `service_timeout`. Generally you want them to be at least 1s lower, so as to account for time spent elsewhere during the request's lifetime while still giving libraries a chance to time out before Rack::Timeout.

[ruby-timeouts]: https://github.com/ankane/the-ultimate-guide-to-ruby-timeouts


Request Lifetime
----------------

Throughout a request's lifetime, Rack::Timeout keeps details about the request in `env[Rack::Timeout::ENV_INFO_KEY]`, or, more explicitly, `env["rack-timeout.info"]`.

The value of that entry is an instance of `Rack::Timeout::RequestDetails`, which is a `Struct` consisting of the following fields:

*   `id`: a unique ID per request. Either the value of the `X-Request-ID` header or a random ID
    generated internally.

*   `wait`: time in seconds since `X-Request-Start` at the time the request was initially seen by Rack::Timeout. Only set if `X-Request-Start` is present.

*   `timeout`: the final timeout value that was used or to be used, in seconds. For `expired` requests, that would be the `wait_timeout`, possibly with `wait_overtime` applied. In all other cases it's the `service_timeout`, potentially reduced to make up for time lost waiting. (See discussion regarding `service_past_wait` above, under the Wait Timeout section.)

*   `service`: set after a request completes (or times out). The time in seconds it took being processed. This is also updated while a request is still active, around every second, with the time taken so far.

*   `state`: the possible states, and their log level, are:

    *   `expired` (`ERROR`): the request is considered too old and is skipped entirely. This happens when `X-Request-Start` is present and older than `wait_timeout`. When in this state, `Rack::Timeout::RequestExpiryError` is raised. See earlier discussion about the `wait_overtime` setting, too.

    *   `ready` (`INFO`): this is the state a request is in right before it's passed down the middleware chain. Once it's being processed, it'll move on to `active`, and then on to `timed_out` and/or `completed`.

    *   `active` (`DEBUG`): the request is being actively processed in the application thread. This is signaled repeatedly every ~1s until the request completes or times out.

    *   `timed_out` (`ERROR`): the request ran for longer than the determined timeout and was aborted. `Rack::Timeout::RequestTimeoutException` is raised in the application when this occurs. This state is not the final one, `completed` will be set after the framework is done with it. (If the exception does bubble up, it's caught by rack-timeout and re-raised as `Rack::Timeout::RequestTimeoutError`, which descends from RuntimeError.)

    *   `completed` (`INFO`): the request completed and Rack::Timeout is done with it. This does not mean the request completed *successfully*. Rack::Timeout does not concern itself with that. As mentioned just above, a timed out request will still end up with a `completed` state.


Errors
------

Rack::Timeout can raise three types of exceptions. They are:

Two descend from `Rack::Timeout::Error`, which itself descends from `RuntimeError` and is generally caught by an unqualified `raise`. The third, `RequestTimeoutException`, is more complicated and the most important.

*   `Rack::Timeout::RequestExpiryError`: this is raised when a request is skipped for being too old (see Wait Timeout section). This error cannot generally be rescued from inside a Rails controller action as it happens before the request has a chance to enter Rails.

    This shouldn't be different for other frameworks, unless you have something above Rack::Timeout in the middleware stack, which you generally shouldn't.

*   `Rack::Timeout::RequestTimeoutException`: this is raised when a request has run for longer than the specified timeout. This descends from `Exception`, not from `Rack::Timeout::Error` (it has to be rescued from explicitly). It's raised by the rack-timeout timer thread in the application thread, at the point in the stack the app happens to be in when the timeout is triggered. This exception could be caught explicitly within the application, but in doing so you're working past the timeout. This is ok for quick cleanup work but shouldn't be abused as Rack::Timeout will not kick in twice for the same request.

    Rails will generally intercept `Exception`s, but in plain Rack apps, this exception will be caught by rack-timeout and re-raised as a `Rack::Timeout::RequestTimeoutError`. This is to prevent an `Exception` from bubbling up beyond rack-timeout and to the server.

*   `Rack::Timeout::RequestTimeoutError` is the third type, it descends from `Rack::Timeout::Error`, but it's only really seen in the case described above. It'll not be seen in a standard Rails app, and will only be seen in Sinatra if rescuing from exceptions is disabled.

You shouldn't rescue from these errors for reporting purposes. Instead, you can subscribe for state change notifications with observers.

If you're trying to test that a `Rack::Timeout::RequestTimeoutException` is raised in an action in your Rails application, you **must do so in integration tests**. Please note that Rack::Timeout will not kick in for functional tests as they bypass the rack middleware stack.

[More details about testing middleware with Rails here][pablobm].

[pablobm]: http://stackoverflow.com/a/8681208/13989


### Rollbar

Because rack-timeout may raise at any point in the codepath of a timed-out request, the stack traces for similar requests may differ, causing rollbar to create separate entries for each timeout.

A Rollbar module is provided which causes rack-timeout errors to be grouped by exception type, request HTTP method, and URL, so all timeouts for a particular endpoint are reported under the same entry.

To enable it, simply require it after having required rollbar. For example, in your rollbar initializer file, do:

    require "rollbar"
    require "rack/timeout/rollbar"

It'll set itself up.

If you wish to use a custom fingerprint for grouping:

    Rack::Timeout::Rollbar.fingerprint do |exception, env|
      # return a string derived from exception and env
    end



Observers
---------

Observers are blocks that are notified about state changes during a request's lifetime. Keep in mind that the `active` state is set every ~1s, so you'll be notified every time.

You can register an observer with:

```ruby
Rack::Timeout.register_state_change_observer(:a_unique_name) { |env| do_things env }
```

There's currently no way to subscribe to changes into or out of a particular state. To check the actual state we're moving into, read `env['rack-timeout.info'].state`. Handling going out of a state would require some additional logic in the observer.

You can remove an observer with `unregister_state_change_observer`:

```ruby
Rack::Timeout.unregister_state_change_observer(:a_unique_name)
```

rack-timeout's logging is implemented using an observer; see `Rack::Timeout::StateChangeLoggingObserver` in logging-observer.rb for the implementation.

Custom observers might be used to do cleanup, store statistics on request length, timeouts, etc., and potentially do performance tuning on the fly.


Logging
-------

Rack::Timeout logs a line every time there's a change in state in a request's lifetime.

Request state changes into `timed_out` and `expired` are logged at the `ERROR` level, most other things are logged as `INFO`. The `active` state is logged as `DEBUG`, every ~1s while the request is still active.

Rack::Timeout will try to use `Rails.logger` if present, otherwise it'll look for a logger in `env['rack.logger']`, and if neither are present, it'll create its own logger, either writing to `env['rack.errors']`, or to `$stderr` if the former is not set.

When creating its own logger, rack-timeout will use a log level of `INFO`. Otherwise whatever log level is already set on the logger being used continues in effect.

A custom logger can be set via `Rack::Timeout::Logger.logger`. This takes priority over the automatic logger detection:

```ruby
Rack::Timeout::Logger.logger = Logger.new
```

There are helper setters that replace the logger:

```ruby
Rack::Timeout::Logger.device = $stderr
Rack::Timeout::Logger.level  = Logger::INFO
```

Although each call replaces the logger, these can be use together and the final logger will retain both properties. (If only one is called, the defaults used above apply.)

Logging is enabled by default, but can be removed with:

```ruby
Rack::Timeout::Logger.disable
```

Each log line is a set of `key=value` pairs, containing the entries from the `env["rack-timeout.info"]` struct that are not `nil`. See the Request Lifetime section above for a description of each field. Note that while the values for `wait`, `timeout`, and `service` are stored internally as seconds, they are logged as milliseconds for readability.

A sample log excerpt might look like:

```
source=rack-timeout id=13793c wait=369ms timeout=10000ms state=ready at=info
source=rack-timeout id=13793c wait=369ms timeout=10000ms service=15ms state=completed at=info
source=rack-timeout id=ea7bd3 wait=371ms timeout=10000ms state=timed_out at=error
```


Compatibility
-------------

This version of Rack::Timeout is compatible with Ruby 2.1 and up, and, for Rails apps, Rails 3.x and up.


---
Copyright © 2010-2016 Caio Chassot, released under the MIT license  
<http://github.com/heroku/rack-timeout>
