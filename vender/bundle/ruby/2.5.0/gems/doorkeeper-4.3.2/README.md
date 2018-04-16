# Doorkeeper - awesome OAuth 2 provider for your Rails app.

[![Gem Version](https://badge.fury.io/rb/doorkeeper.svg)](https://rubygems.org/gems/doorkeeper)
[![Build Status](https://travis-ci.org/doorkeeper-gem/doorkeeper.svg?branch=master)](https://travis-ci.org/doorkeeper-gem/doorkeeper)
[![Dependency Status](https://gemnasium.com/doorkeeper-gem/doorkeeper.svg?travis)](https://gemnasium.com/doorkeeper-gem/doorkeeper)
[![Code Climate](https://codeclimate.com/github/doorkeeper-gem/doorkeeper.svg)](https://codeclimate.com/github/doorkeeper-gem/doorkeeper)
[![Coverage Status](https://coveralls.io/repos/github/doorkeeper-gem/doorkeeper/badge.svg?branch=master)](https://coveralls.io/github/doorkeeper-gem/doorkeeper?branch=master)
[![Security](https://hakiri.io/github/doorkeeper-gem/doorkeeper/master.svg)](https://hakiri.io/github/doorkeeper-gem/doorkeeper/master)

Doorkeeper is a gem that makes it easy to introduce OAuth 2 provider
functionality to your Rails or Grape application.

Supported features:

- [The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
  - [Authorization Code Flow](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1)
  - [Access Token Scopes](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-3.3)
  - [Refresh token](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-1.5)
  - [Implicit grant](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.2)
  - [Resource Owner Password Credentials](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.3)
  - [Client Credentials](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.4)
- [OAuth 2.0 Token Revocation](http://tools.ietf.org/html/rfc7009)
- [OAuth 2.0 Token Introspection](https://tools.ietf.org/html/rfc7662)

## Documentation valid for `master` branch

Please check the documentation for the version of doorkeeper you are using in:
https://github.com/doorkeeper-gem/doorkeeper/releases

- See the [wiki](https://github.com/doorkeeper-gem/doorkeeper/wiki)
- For general questions, please post in [Stack Overflow](http://stackoverflow.com/questions/tagged/doorkeeper)
- See [SECURITY.md](SECURITY.md) for this project's security disclose
  policy

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Installation](#installation)
- [Configuration](#configuration)
  - [ORM](#orm)
    - [Active Record](#active-record)
    - [MongoDB](#mongodb)
    - [Sequel](#sequel)
    - [Couchbase](#couchbase)
  - [Routes](#routes)
  - [Authenticating](#authenticating)
  - [Internationalization (I18n)](#internationalization-i18n)
- [Protecting resources with OAuth (a.k.a your API endpoint)](#protecting-resources-with-oauth-aka-your-api-endpoint)
  - [Ruby on Rails controllers](#ruby-on-rails-controllers)
  - [Grape endpoints](#grape-endpoints)
  - [Route Constraints and other integrations](#route-constraints-and-other-integrations)
  - [Access Token Scopes](#access-token-scopes)
  - [Custom Access Token Generator](#custom-access-token-generator)
  - [Authenticated resource owner](#authenticated-resource-owner)
  - [Applications list](#applications-list)
- [Other customizations](#other-customizations)
- [Testing](#testing)
- [Upgrading](#upgrading)
- [Development](#development)
- [Contributing](#contributing)
- [Other resources](#other-resources)
  - [Wiki](#wiki)
  - [Screencast](#screencast)
  - [Client applications](#client-applications)
  - [Contributors](#contributors)
  - [IETF Standards](#ietf-standards)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

Put this in your Gemfile:

``` ruby
gem 'doorkeeper'
```

Run the installation generator with:

    rails generate doorkeeper:install

This will install the doorkeeper initializer into `config/initializers/doorkeeper.rb`.

## Configuration

### ORM

#### Active Record

By default doorkeeper is configured to use Active Record, so to start you have
to generate the migration tables (supports Rails >= 5 migrations versioning):

    rails generate doorkeeper:migration

You may want to add foreign keys to your migration. For example, if you plan on
using `User` as the resource owner, add the following line to the migration file
for each table that includes a `resource_owner_id` column:

```ruby
add_foreign_key :table_name, :users, column: :resource_owner_id
```

Then run migrations:

```sh
rake db:migrate
```

Remember to add associations to your model so the related records are deleted.
If you don't do this an `ActiveRecord::InvalidForeignKey`-error will be raised
when you try to destroy a model with related access grants or access tokens.

```ruby
class User < ApplicationRecord
  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks
end
```

#### MongoDB

See [doorkeeper-mongodb project] for Mongoid and MongoMapper support. Follow along
the implementation in that repository to extend doorkeeper with other ORMs.

[doorkeeper-mongodb project]: https://github.com/doorkeeper-gem/doorkeeper-mongodb

#### Sequel

If you are using [Sequel gem] then you can add [doorkeeper-sequel extension] to your project.
Follow configuration instructions for setting up the necessary Doorkeeper ORM.

[Sequel gem]: https://github.com/jeremyevans/sequel/
[doorkeeper-sequel extension]: https://github.com/nbulaj/doorkeeper-sequel

#### Couchbase

Use [doorkeeper-couchbase] extension if you are using Couchbase database.

[doorkeeper-couchbase]: https://github.com/acaprojects/doorkeeper-couchbase

### Routes

The installation script will also automatically add the Doorkeeper routes into
your app, like this:

``` ruby
Rails.application.routes.draw do
  use_doorkeeper
  # your routes
end
```

This will mount following routes:

    GET       /oauth/authorize/native?code
    GET       /oauth/authorize
    POST      /oauth/authorize
    DELETE    /oauth/authorize
    POST      /oauth/token
    POST      /oauth/revoke
    POST      /oauth/introspect
    resources /oauth/applications
    GET       /oauth/authorized_applications
    DELETE    /oauth/authorized_applications/:id
    GET       /oauth/token/info

For more information on how to customize routes, check out [this page on the
wiki](https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes).

### Authenticating

You need to configure Doorkeeper in order to provide `resource_owner` model
and authentication block in `config/initializers/doorkeeper.rb`:

``` ruby
Doorkeeper.configure do
  resource_owner_authenticator do
    User.find_by(id: session[:current_user_id]) || redirect_to(login_url)
  end
end
```

This code is run in the context of your application so you have access to your
models, session or routes helpers. However, since this code is not run in the
context of your application's `ApplicationController` it doesn't have access to
the methods defined over there.

You may want to check other ways of authentication
[here](https://github.com/doorkeeper-gem/doorkeeper/wiki/Authenticating-using-Clearance-or-DIY).

### Internationalization (I18n)

See language files in [the I18n repository](https://github.com/doorkeeper-gem/doorkeeper-i18n).

## Protecting resources with OAuth (a.k.a your API endpoint)

### Ruby on Rails controllers

To protect your controllers (usual one or `ActionController::API`) with OAuth,
you just need to setup `before_action`s specifying the actions you want to
protect. For example:

``` ruby
class Api::V1::ProductsController < Api::V1::ApiController
  before_action :doorkeeper_authorize! # Require access token for all actions

  # your actions
end
```

You can pass any option `before_action` accepts, such as `if`, `only`,
`except`, and others.

### Grape endpoints

Starting from version 2.2 Doorkeeper provides helpers for the
[Grape framework] >= 0.10. One of them is `doorkeeper_authorize!` that
can be used in a similar way as an example above to protect your API
with OAuth. Note that you have to use `require 'doorkeeper/grape/helpers'`
and `helpers Doorkeeper::Grape::Helpers` in your Grape API class.

For more information about integration with Grape see the [Wiki].

[Grape framework]: https://github.com/ruby-grape/grape
[Wiki]: https://github.com/doorkeeper-gem/doorkeeper/wiki/Grape-Integration

``` ruby
require 'doorkeeper/grape/helpers'

module API
  module V1
    class Users < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!
      end

      # route_setting :scopes, ['user:email'] - for old versions of Grape
      get :emails, scopes: [:user, :write] do
        [{'email' => current_user.email}]
      end

      # ...
    end
  end
end
```

### Route Constraints and other integrations

You can leverage the `Doorkeeper.authenticate` facade to easily extract a
`Doorkeeper::OAuth::Token` based on the current request. You can then ensure
that token is still good, find its associated `#resource_owner_id`, etc.

```ruby
module Constraint
  class Authenticated

    def matches?(request)
      token = Doorkeeper.authenticate(request)
      token && token.accessible?
    end
  end
end
```

For more information about integration and other integrations, check out [the
related wiki
page](https://github.com/doorkeeper-gem/doorkeeper/wiki/ActionController::Metal-with-doorkeeper).

### Access Token Scopes

You can also require the access token to have specific scopes in certain
actions:

First configure the scopes in `initializers/doorkeeper.rb`

```ruby
Doorkeeper.configure do
  default_scopes :public # if no scope was requested, this will be the default
  optional_scopes :admin, :write
end
```

And in your controllers:

```ruby
class Api::V1::ProductsController < Api::V1::ApiController
  before_action -> { doorkeeper_authorize! :public }, only: :index
  before_action only: [:create, :update, :destroy] do
    doorkeeper_authorize! :admin, :write
  end
end
```

Please note that there is a logical OR between multiple required scopes. In the
above example, `doorkeeper_authorize! :admin, :write` means that the access
token is required to have either `:admin` scope or `:write` scope, but does not
need have both of them.

If you want to require the access token to have multiple scopes at the same
time, use multiple `doorkeeper_authorize!`, for example:

```ruby
class Api::V1::ProductsController < Api::V1::ApiController
  before_action -> { doorkeeper_authorize! :public }, only: :index
  before_action only: [:create, :update, :destroy] do
    doorkeeper_authorize! :admin
    doorkeeper_authorize! :write
  end
end
```

In the above example, a client can call `:create` action only if its access token
has both `:admin` and `:write` scopes.

### Custom Access Token Generator

By default a 128 bit access token will be generated. If you require a custom
token, such as [JWT](http://jwt.io), specify an object that responds to
`.generate(options = {})` and returns a string to be used as the token.

```ruby
Doorkeeper.configure do
  access_token_generator "Doorkeeper::JWT"
end
```

JWT token support is available with
[Doorkeeper-JWT](https://github.com/chriswarren/doorkeeper-jwt).

### Custom Base Controller

By default Doorkeeper's main controller `Doorkeeper::ApplicationController`
inherits from `ActionController::Base`. You may want to use your own
controller to inherit from, to keep Doorkeeper controllers in the same
context than the rest your app:

```ruby
Doorkeeper.configure do
  base_controller 'ApplicationController'
end
```

### Authenticated resource owner

If you want to return data based on the current resource owner, in other
words, the access token owner, you may want to define a method in your
controller that returns the resource owner instance:

``` ruby
class Api::V1::CredentialsController < Api::V1::ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  # GET /me.json
  def me
    respond_with current_resource_owner
  end

  private

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
```

In this example, we're returning the credentials (`me.json`) of the access
token owner.

### Applications list

By default, the applications list (`/oauth/applications`) is publicly available.
To protect the endpoint you should uncomment these lines:

```ruby
# config/initializers/doorkeeper.rb
Doorkeeper.configure do
  admin_authenticator do |routes|
    Admin.find_by(id: session[:admin_id]) || redirect_to(routes.new_admin_session_url)
  end
end
```

The logic is the same as the `resource_owner_authenticator` block. **Note:**
since the application list is just a scaffold, it's recommended to either
customize the controller used by the list or skip the controller all together.
For more information see the page
[in the wiki](https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes).

## Other customizations

- [Associate users to OAuth applications (ownership)](https://github.com/doorkeeper-gem/doorkeeper/wiki/Associate-users-to-OAuth-applications-%28ownership%29)
- [CORS - Cross Origin Resource Sharing](https://github.com/doorkeeper-gem/doorkeeper/wiki/%5BCORS%5D-Cross-Origin-Resource-Sharing)
- see more on [Wiki page](https://github.com/doorkeeper-gem/doorkeeper/wiki)

## Testing

You can use Doorkeeper models in your application test suite. Note that starting from
Doorkeeper 4.3.0 it uses [ActiveSupport lazy loading hooks](http://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)
to load models. There are [known issue](https://github.com/doorkeeper-gem/doorkeeper/issues/1043)
with the `factory_bot_rails` gem (it executes factories building before `ActiveRecord::Base`
is initialized using hooks in gem railtie, so you can catch a `uninitialized constant` error).
It is recommended to use pure `factory_bot` gem to solve this problem. 

## Upgrading

If you want to upgrade doorkeeper to a new version, check out the [upgrading
notes](https://github.com/doorkeeper-gem/doorkeeper/wiki/Migration-from-old-versions)
and take a look at the
[changelog](https://github.com/doorkeeper-gem/doorkeeper/blob/master/NEWS.md).

Doorkeeper follows [semantic versioning](http://semver.org/).

## Development

To run the local engine server:

```
bundle install
bundle exec rails server
````

By default, it uses the latest Rails version with ActiveRecord. To run the
tests with a specific ORM and Rails version:

```
rails=4.2.0 orm=active_record bundle exec rake
```

## Contributing

Want to contribute and don't know where to start? Check out [features we're
missing](https://github.com/doorkeeper-gem/doorkeeper/wiki/Supported-Features),
create [example
apps](https://github.com/doorkeeper-gem/doorkeeper/wiki/Example-Applications),
integrate the gem with your app and let us know!

Also, check out our [contributing guidelines
page](https://github.com/doorkeeper-gem/doorkeeper/wiki/Contributing).

## Other resources

### Wiki

You can find everything about Doorkeeper in our [wiki
here](https://github.com/doorkeeper-gem/doorkeeper/wiki).

### Screencast

Check out this screencast from [railscasts.com](http://railscasts.com/): [#353
OAuth with
Doorkeeper](http://railscasts.com/episodes/353-oauth-with-doorkeeper)

### Client applications

After you set up the provider, you may want to create a client application to
test the integration. Check out these [client
examples](https://github.com/doorkeeper-gem/doorkeeper/wiki/Example-Applications)
in our wiki or follow this [tutorial
here](https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem).

### Contributors

Thanks to all our [awesome
contributors](https://github.com/doorkeeper-gem/doorkeeper/graphs/contributors)!

### IETF Standards

* [The OAuth 2.0 Authorization Framework](http://tools.ietf.org/html/rfc6749)
* [OAuth 2.0 Threat Model and Security Considerations](http://tools.ietf.org/html/rfc6819)
* [OAuth 2.0 Token Revocation](http://tools.ietf.org/html/rfc7009)

### License

MIT License. Copyright 2011 Applicake.
