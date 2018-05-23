# Rack::Attack

*Rack middleware for blocking & throttling abusive requests*

Protect your Rails and Rack apps from bad clients. Rack::Attack lets you easily decide when to *allow*, *block* and *throttle* based on properties of the request.

See the [Backing & Hacking blog post](http://www.kickstarter.com/backing-and-hacking/rack-attack-protection-from-abusive-clients) introducing Rack::Attack.

[![Gem Version](https://badge.fury.io/rb/rack-attack.svg)](http://badge.fury.io/rb/rack-attack)
[![Build Status](https://travis-ci.org/kickstarter/rack-attack.svg?branch=master)](https://travis-ci.org/kickstarter/rack-attack)
[![Code Climate](https://codeclimate.com/github/kickstarter/rack-attack.svg)](https://codeclimate.com/github/kickstarter/rack-attack)

## Getting started

### 1. Installing

Add this line to your application's Gemfile:

```ruby
# In your Gemfile

gem 'rack-attack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-attack

### 2. Plugging into the application

Then tell your ruby web application to use rack-attack as a middleware.

a) For __rails__ applications:

```ruby
# In config/application.rb

config.middleware.use Rack::Attack
```

b) For __rack__ applications:

```ruby
# In config.ru

require "rack/attack"
use Rack::Attack
```

__IMPORTANT__: By default, rack-attack won't perform any blocking or throttling, until you specifically tell it what to protect against by configuring some rules.

## Usage

*Tip:* The example in the wiki is a great way to get started:
[Example Configuration](https://github.com/kickstarter/rack-attack/wiki/Example-Configuration)

Define rules by calling `Rack::Attack` public methods, in any file that runs when your application is being initialized. For rails applications this means creating a new file named `config/initializers/rack_attack.rb` and writing your rules there.

### Safelisting

Safelists have the most precedence, so any request matching a safelist would be allowed despite matching any number of blocklists or throttles.

#### `safelist_ip(ip_address_string)`

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails app)

Rack::Attack.safelist_ip("5.6.7.8")
```

#### `safelist_ip(ip_subnet_string)`

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails app)

Rack::Attack.safelist_ip("5.6.7.0/24")
```

#### `safelist(name, &block)`

Name your custom safelist and make your ruby-block argument return a truthy value if you want the request to be blocked, and falsy otherwise.

The request object is a [Rack::Request](http://www.rubydoc.info/gems/rack/Rack/Request).

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails apps)

# Provided that trusted users use an HTTP request header named APIKey
Rack::Attack.safelist("mark any authenticated access safe") do |request|
  # Requests are allowed if the return value is truthy
  request.env["APIKey"] == "secret-string"
end

# Always allow requests from localhost
# (blocklist & throttles are skipped)
Rack::Attack.safelist('allow from localhost') do |req|
  # Requests are allowed if the return value is truthy
  '127.0.0.1' == req.ip || '::1' == req.ip
end
```

### Blocking

#### `blocklist_ip(ip_address_string)`

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails apps)

Rack::Attack.blocklist_ip("1.2.3.4")
```

#### `blocklist_ip(ip_subnet_string)`

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails apps)

Rack::Attack.blocklist_ip("1.2.0.0/16")
```

#### `blocklist(name, &block)`

Name your custom blocklist and make your ruby-block argument returna a truthy value if you want the request to be blocked, and falsy otherwise.

The request object is a [Rack::Request](http://www.rubydoc.info/gems/rack/Rack/Request).

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails apps)

Rack::Attack.blocklist("block all access to admin") do |request|
  # Requests are blocked if the return value is truthy
  request.path.start_with?("/admin")
end

Rack::Attack.blocklist('block bad UA logins') do |req|
  req.path == '/login' && req.post? && req.user_agent == 'BadUA'
end
```

#### Fail2Ban

`Fail2Ban.filter` can be used within a blocklist to block all requests from misbehaving clients.
This pattern is inspired by [fail2ban](http://www.fail2ban.org/wiki/index.php/Main_Page).
See the [fail2ban documentation](http://www.fail2ban.org/wiki/index.php/MANUAL_0_8#Jail_Options) for more details on
how the parameters work.  For multiple filters, be sure to put each filter in a separate blocklist and use a unique discriminator for each fail2ban filter.

Fail2ban state is stored in a [configurable cache](#cache-store-configuration) (which defaults to `Rails.cache` if present).

```ruby
# Block suspicious requests for '/etc/password' or wordpress specific paths.
# After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
    # The count for the IP is incremented if the return value is truthy
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
    req.path.include?('/etc/passwd') ||
    req.path.include?('wp-admin') ||
    req.path.include?('wp-login')

  end
end
```

Note that `Fail2Ban` filters are not automatically scoped to the blocklist, so when using multiple filters in an application the scoping must be added to the discriminator e.g. `"pentest:#{req.ip}"`.

#### Allow2Ban

`Allow2Ban.filter` works the same way as the `Fail2Ban.filter` except that it *allows* requests from misbehaving
clients until such time as they reach maxretry at which they are cut off as per normal.

Allow2ban state is stored in a [configurable cache](#cache-store-configuration) (which defaults to `Rails.cache` if present).

```ruby
# Lockout IP addresses that are hammering your login page.
# After 20 requests in 1 minute, block all requests from that IP for 1 hour.
Rack::Attack.blocklist('allow2ban login scrapers') do |req|
  # `filter` returns false value if request is to your login page (but still
  # increments the count) so request below the limit are not blocked until
  # they hit the limit.  At that point, filter will return true and block.
  Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 20, findtime: 1.minute, bantime: 1.hour) do
    # The count for the IP is incremented if the return value is truthy.
    req.path == '/login' and req.post?
  end
end
```

### Throttling

Throttle state is stored in a [configurable cache](#cache-store-configuration) (which defaults to `Rails.cache` if present).

#### `throttle(name, options, &block)`

Name your custom throttle, provide `limit` and `period` as options, and make your ruby-block argument return the __discriminator__. This discriminator is how you tell rack-attack whether you're limiting per IP address, per user email or any other.

The request object is a [Rack::Request](http://www.rubydoc.info/gems/rack/Rack/Request).

E.g.

```ruby
# config/initializers/rack_attack.rb (for rails apps)

Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |request|
  request.ip
end

# Throttle login attempts for a given email parameter to 6 reqs/minute
# Return the email as a discriminator on POST /login requests
Rack::Attack.throttle('limit logins per email', limit: 6, period: 60) do |req|
  if req.path == '/login' && req.post?
    req.params['email']
  end
end

# You can also set a limit and period using a proc. For instance, after
# Rack::Auth::Basic has authenticated the user:
limit_proc = proc { |req| req.env["REMOTE_USER"] == "admin" ? 100 : 1 }
period_proc = proc { |req| req.env["REMOTE_USER"] == "admin" ? 1 : 60 }

Rack::Attack.throttle('request per ip', limit: limit_proc, period: period_proc) do |request|
  request.ip
end
```

### Tracks

```ruby
# Track requests from a special user agent.
Rack::Attack.track("special_agent") do |req|
  req.user_agent == "SpecialAgent"
end

# Supports optional limit and period, triggers the notification only when the limit is reached.
Rack::Attack.track("special_agent", limit: 6, period: 60) do |req|
  req.user_agent == "SpecialAgent"
end

# Track it using ActiveSupport::Notification
ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  if req.env['rack.attack.matched'] == "special_agent" && req.env['rack.attack.match_type'] == :track
    Rails.logger.info "special_agent: #{req.path}"
    STATSD.increment("special_agent")
  end
end
```

### Cache store configuration

Throttle, allow2ban and fail2ban state is stored in a configurable cache (which defaults to `Rails.cache` if present), presumably backed by memcached or redis ([at least gem v3.0.0](https://rubygems.org/gems/redis)).

```ruby
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new # defaults to Rails.cache
```

Note that `Rack::Attack.cache` is only used for throttling, allow2ban and fail2ban filtering; not blocklisting and safelisting. Your cache store must implement `increment` and `write` like [ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html).

## Customizing responses

Customize the response of blocklisted and throttled requests using an object that adheres to the [Rack app interface](http://rack.rubyforge.org/doc/SPEC.html).

```ruby
Rack::Attack.blocklisted_response = lambda do |env|
  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 403 for blocklists by default
  [ 503, {}, ['Blocked']]
end

Rack::Attack.throttled_response = lambda do |env|
  # NB: you have access to the name and other data about the matched throttle
  #  env['rack.attack.matched'],
  #  env['rack.attack.match_type'],
  #  env['rack.attack.match_data'],
  #  env['rack.attack.match_discriminator']

  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 429 for throttling by default
  [ 503, {}, ["Server Error\n"]]
end
```

### X-RateLimit headers for well-behaved clients

While Rack::Attack's primary focus is minimizing harm from abusive clients, it
can also be used to return rate limit data that's helpful for well-behaved clients.

Here's an example response that includes conventional `X-RateLimit-*` headers:

```ruby
Rack::Attack.throttled_response = lambda do |env|
  now = Time.now
  match_data = env['rack.attack.match_data']

  headers = {
    'X-RateLimit-Limit' => match_data[:limit].to_s,
    'X-RateLimit-Remaining' => '0',
    'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  }

  [ 429, headers, ["Throttled\n"]]
end
```


For responses that did not exceed a throttle limit, Rack::Attack annotates the env with match data:

```ruby
request.env['rack.attack.throttle_data'][name] # => { :count => n, :period => p, :limit => l }
```

## Logging & Instrumentation

Rack::Attack uses the [ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) API if available.

You can subscribe to 'rack.attack' events and log it, graph it, etc:

```ruby
ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  puts req.inspect
end
```

## How it works

The Rack::Attack middleware compares each request against *safelists*, *blocklists*, *throttles*, and *tracks* that you define. There are none by default.

 * If the request matches any **safelist**, it is allowed.
 * Otherwise, if the request matches any **blocklist**, it is blocked.
 * Otherwise, if the request matches any **throttle**, a counter is incremented in the Rack::Attack.cache. If any throttle's limit is exceeded, the request is blocked.
 * Otherwise, all **tracks** are checked, and the request is allowed.

The algorithm is actually more concise in code: See [Rack::Attack.call](https://github.com/kickstarter/rack-attack/blob/master/lib/rack/attack.rb):

```ruby
def call(env)
  req = Rack::Attack::Request.new(env)

  if safelisted?(req)
    @app.call(env)
  elsif blocklisted?(req)
    self.class.blocklisted_response.call(env)
  elsif throttled?(req)
    self.class.throttled_response.call(env)
  else
    tracked?(req)
    @app.call(env)
  end
end
```

Note: `Rack::Attack::Request` is just a subclass of `Rack::Request` so that you
can cleanly monkey patch helper methods onto the
[request object](https://github.com/kickstarter/rack-attack/blob/master/lib/rack/attack/request.rb).

### About Tracks

`Rack::Attack.track` doesn't affect request processing. Tracks are an easy way to log and measure requests matching arbitrary attributes.


## Testing

A note on developing and testing apps using Rack::Attack - if you are using throttling in particular, you will
need to enable the cache in your development environment. See [Caching with Rails](http://guides.rubyonrails.org/caching_with_rails.html)
for more on how to do this.

## Performance

The overhead of running Rack::Attack is typically negligible (a few milliseconds per request),
but it depends on how many checks you've configured, and how long they take.
Throttles usually require a network roundtrip to your cache server(s),
so try to keep the number of throttle checks per request low.

If a request is blocklisted or throttled, the response is a very simple Rack response.
A single typical ruby web server thread can block several hundred requests per second.

Rack::Attack complements tools like `iptables` and nginx's [limit_conn_zone module](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html#limit_conn_zone).

## Motivation

Abusive clients range from malicious login crackers to naively-written scrapers.
They hinder the security, performance, & availability of web applications.

It is impractical if not impossible to block abusive clients completely.

Rack::Attack aims to let developers quickly mitigate abusive requests and rely
less on short-term, one-off hacks to block a particular attack.

## Contributing

Pull requests and issues are greatly appreciated. This project is intended to be
a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

### Testing pull requests

To run the minitest test suite, you will need both [Redis](http://redis.io/) and
[Memcached](https://memcached.org/) running locally and bound to IP `127.0.0.1` on
default ports (`6379` for Redis, and `11211` for Memcached) and able to be
accessed without authentication.

Install dependencies by running
```sh
bundle install
```

Then run the test suite by running
```sh
bundle exec rake
```

## Mailing list

New releases of Rack::Attack are announced on
<rack.attack.announce@librelist.com>. To subscribe, just send an email to
<rack.attack.announce@librelist.com>. See the
[archives](http://librelist.com/browser/rack.attack.announce/).

## License

Copyright Kickstarter, PBC.

Released under an [MIT License](http://opensource.org/licenses/MIT).
