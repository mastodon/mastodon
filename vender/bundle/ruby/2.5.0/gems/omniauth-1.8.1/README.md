# OmniAuth: Standardized Multi-Provider Authentication

[![Gem Version](http://img.shields.io/gem/v/omniauth.svg)][gem]
[![Build Status](http://img.shields.io/travis/omniauth/omniauth.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/omniauth/omniauth.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/omniauth/omniauth.svg)][codeclimate]
[![Coverage Status](http://img.shields.io/coveralls/omniauth/omniauth.svg)][coveralls]
[![Security](https://hakiri.io/github/omniauth/omniauth/master.svg)](https://hakiri.io/github/omniauth/omniauth/master)

[gem]: https://rubygems.org/gems/omniauth
[travis]: http://travis-ci.org/omniauth/omniauth
[gemnasium]: https://gemnasium.com/omniauth/omniauth
[codeclimate]: https://codeclimate.com/github/omniauth/omniauth
[coveralls]: https://coveralls.io/r/omniauth/omniauth

## An Introduction
OmniAuth is a library that standardizes multi-provider authentication for
web applications. It was created to be powerful, flexible, and do as
little as possible. Any developer can create **strategies** for OmniAuth
that can authenticate users via disparate systems. OmniAuth strategies
have been created for everything from Facebook to LDAP.

In order to use OmniAuth in your applications, you will need to leverage
one or more strategies. These strategies are generally released
individually as RubyGems, and you can see a [community maintained list](https://github.com/omniauth/omniauth/wiki/List-of-Strategies)
on the wiki for this project.

One strategy, called `Developer`, is included with OmniAuth and provides
a completely insecure, non-production-usable strategy that directly
prompts a user for authentication information and then passes it
straight through. You can use it as a placeholder when you start
development and easily swap in other strategies later.

## Getting Started
Each OmniAuth strategy is a Rack Middleware. That means that you can use
it the same way that you use any other Rack middleware. For example, to
use the built-in Developer strategy in a Sinatra application I might do
this:

```ruby
require 'sinatra'
require 'omniauth'

class MyApplication < Sinatra::Base
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Developer
end
```

Because OmniAuth is built for *multi-provider* authentication, I may
want to leave room to run multiple strategies. For this, the built-in
`OmniAuth::Builder` class gives you an easy way to specify multiple
strategies. Note that there is **no difference** between the following
code and using each strategy individually as middleware. This is an
example that you might put into a Rails initializer at
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
```

You should look to the documentation for each provider you use for
specific initialization requirements.

## Integrating OmniAuth Into Your Application
OmniAuth is an extremely low-touch library. It is designed to be a
black box that you can send your application's users into when you need
authentication and then get information back. OmniAuth was intentionally
built not to automatically associate with a User model or make
assumptions about how many authentication methods you might want to use
or what you might want to do with the data once a user has
authenticated. This makes OmniAuth incredibly flexible. To use OmniAuth,
you need only to redirect users to `/auth/:provider`, where `:provider`
is the name of the strategy (for example, `developer` or `twitter`).
From there, OmniAuth will take over and take the user through the
necessary steps to authenticate them with the chosen strategy.

Once the user has authenticated, what do you do next? OmniAuth simply
sets a special hash called the Authentication Hash on the Rack
environment of a request to `/auth/:provider/callback`. This hash
contains as much information about the user as OmniAuth was able to
glean from the utilized strategy. You should set up an endpoint in your
application that matches to the callback URL and then performs whatever
steps are necessary for your application. For example, in a Rails app I
would add a line in my `routes.rb` file like this:

```ruby
get '/auth/:provider/callback', to: 'sessions#create'
```

And I might then have a `SessionsController` with code that looks
something like this:

```ruby
class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    self.current_user = @user
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
```

The `omniauth.auth` key in the environment hash gives me my
Authentication Hash which will contain information about the just
authenticated user including a unique id, the strategy they just used
for authentication, and personal details such as name and email address
as available. For an in-depth description of what the authentication
hash might contain, see the [Auth Hash Schema wiki page](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema).

Note that OmniAuth does not perform any actions beyond setting some
environment information on the callback request. It is entirely up to
you how you want to implement the particulars of your application's
authentication flow.

## Configuring The `origin` Param
The `origin` url parameter is typically used to inform where a user came from and where, should you choose to use it, they'd want to return to.

There are three possible options:

Default Flow:
```ruby
# /auth/twitter/?origin=[URL]
# No change
# If blank, `omniauth.origin` is set to HTTP_REFERER
```

Renaming Origin Param:
```ruby
# /auth/twitter/?return_to=[URL]
# If blank, `omniauth.origin` is set to HTTP_REFERER
provider :twitter, ENV['KEY'], ENV['SECRET'], origin_param: 'return_to'
```

Disabling Origin Param:
```ruby
# /auth/twitter
# Origin handled externally, if need be. `omniauth.origin` is not set
provider :twitter, ENV['KEY'], ENV['SECRET'], origin_param: false
```

## Integrating OmniAuth Into Your Rails API
The following middleware are (by default) included for session management in
Rails applications. When using OmniAuth with a Rails API, you'll need to add
one of these required middleware back in:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

The trick to adding these back in is that, by default, they are passed
`session_options` when added (including the session key), so you can't just add
a `session_store.rb` initializer, add `use ActionDispatch::Session::CookieStore`
and have sessions functioning as normal.

To be clear: sessions may work, but your session options will be ignored
(i.e the session key will default to `_session_id`).  Instead of the
initializer, you'll have to set the relevant options somewhere
before your middleware is built (like `application.rb`) and pass them to your
preferred middleware, like this:

**application.rb:**

```ruby
config.session_store :cookie_store, key: '_interslice_session'
config.middleware.use ActionDispatch::Cookies # Required for all session management
config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
```

(Thanks @mltsy)

## Logging
OmniAuth supports a configurable logger. By default, OmniAuth will log
to `STDOUT` but you can configure this using `OmniAuth.config.logger`:

```ruby
# Rails application example
OmniAuth.config.logger = Rails.logger
```

## Resources
The [OmniAuth Wiki](https://github.com/omniauth/omniauth/wiki) has
actively maintained in-depth documentation for OmniAuth. It should be
your first stop if you are wondering about a more in-depth look at
OmniAuth, how it works, and how to use it.

## Supported Ruby Versions
OmniAuth is tested under 2.1.10, 2.2.6, 2.3.3, 2.4.0, 2.5.0, and JRuby.

## Versioning
This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    spec.add_dependency 'omniauth', '~> 1.0'

[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint

## License
Copyright (c) 2010-2017 Michael Bleigh and Intridea, Inc. See [LICENSE][] for
details.

[license]: LICENSE.md
