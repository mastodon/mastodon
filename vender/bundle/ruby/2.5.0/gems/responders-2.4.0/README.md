# Responders

[![Gem Version](https://fury-badge.herokuapp.com/rb/responders.svg)](http://badge.fury.io/rb/responders)
[![Build Status](https://api.travis-ci.org/plataformatec/responders.svg?branch=master)](http://travis-ci.org/plataformatec/responders)
[![Code Climate](https://codeclimate.com/github/plataformatec/responders.svg)](https://codeclimate.com/github/plataformatec/responders)

A set of responders modules to dry up your Rails 4.2+ app.

## Installation

Add the responders gem to your Gemfile:

    gem "responders"

Update your bundle and run the install generator:

    $ bundle install
    $ rails g responders:install

If you are including this gem to support backwards compatibilty for responders in previous releases of Rails, you only need to include the gem and bundle.

    $ bundle install

## Responders Types

### FlashResponder

Sets the flash based on the controller action and resource status.
For instance, if you do: `respond_with(@post)` on a POST request and the resource `@post`
does not contain errors, it will automatically set the flash message to
`"Post was successfully created"` as long as you configure your I18n file:

```yaml
  flash:
    actions:
      create:
        notice: "%{resource_name} was successfully created."
      update:
        notice: "%{resource_name} was successfully updated."
      destroy:
        notice: "%{resource_name} was successfully destroyed."
        alert: "%{resource_name} could not be destroyed."
```

In case the resource contains errors, you should use the failure key on I18n. This is
useful to dry up flash messages from your controllers. Note: by default alerts for `update`
and `destroy` actions are commented in generated I18n file. If you need a specific message
for a controller, let's say, for `PostsController`, you can also do:

```yaml
  flash:
    posts:
      create:
        notice: "Your post was created and will be published soon"
```

This responder is activated in all non get requests. By default it will use the keys
`:notice` and `:alert`, but they can be changed in your application:

```ruby
config.responders.flash_keys = [ :success, :failure ]
```

You can also have embedded HTML. Just create a `_html` scope.

```yaml
  flash:
    actions:
      create:
        alert_html: "<strong>OH NOES!</strong> You did it wrong!"
    posts:
      create:
        notice_html: "<strong>Yay!</strong> You did it!"
```

See also the `namespace_lookup` option to search the full hierarchy of possible keys.

### HttpCacheResponder

Automatically adds Last-Modified headers to API requests. This
allows clients to easily query the server if a resource changed and if the client tries
to retrieve a resource that has not been modified, it returns not_modified status.

### CollectionResponder

Makes your create and update action redirect to the collection on success.

### LocationResponder

This responder allows you to use callable objects as the redirect location.
Useful when you want to use the `respond_with` method with
a custom route that requires persisted objects, but the validation may fail.

Note: this responder is included by default, and doesn't need to be included
on the top of your controller (including it will issue a deprecation warning).

```ruby
class ThingsController < ApplicationController
  respond_to :html

  def create
    @thing = Thing.create(params[:thing])
    respond_with @thing, location: -> { thing_path(@thing) }
  end
end
```

**Dealing with namespaced routes**

In order for the LocationResponder to find the correct route helper for namespaced routes you need to pass the namespaces to `respond_with`:

```ruby
class Api::V1::ThingsController < ApplicationController
  respond_to :json

  # POST /api/v1/things
  def create
    @thing = Thing.create(thing_params)
    respond_with :api, :v1, @thing
  end
end
```

## Configuring your own responder

Responders only provides a set of modules and to use them you have to create your own
responder. After you run the install command, the following responder will be
generated in your application:

```ruby
# lib/application_responder.rb
class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder
end
```

Your application also needs to be configured to use it:

```ruby
# app/controllers/application_controller.rb
require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
end
```

## Controller method

This gem also includes the controller method `responders`, which allows you to cherry-pick which
responders you want included in your controller.

```ruby
class InvitationsController < ApplicationController
  responders :flash, :http_cache
end
```

## Interpolation Options

You can pass in extra interpolation options for the translation by adding an `flash_interpolation_options` method to your controller:

```ruby
class InvitationsController < ApplicationController
  responders :flash, :http_cache

  def create
    @invitation = Invitation.create(params[:invitation])
    respond_with @invitation
  end

  private

  def flash_interpolation_options
    { resource_name: @invitation.email }
  end
end
```

Now you would see the message "bob@bob.com was successfully created" instead of the default "Invitation was successfully created."

## Generator

This gem also includes a responders controller generator, so your scaffold can be customized
to use `respond_with` instead of default `respond_to` blocks. From 2.1, you need to explicitly opt-in to use this generator by adding the following to your `config/application.rb`:

    config.app_generators.scaffold_controller :responders_controller

## Failure handling

Responders don't use `valid?` to check for errors in models to figure out if
the request was successfull or not, and relies on your controllers to call
`save` or `create` to trigger the validations.

```ruby
def create
  @widget = Widget.new(widget_params)
  # @widget will be a valid record for responders, as we haven't called `save`
  # on it, and will always redirect to the `widgets_path`.
  respond_with @widget, location: -> { widgets_path }
end
```

Responders will check if the `errors` object in your model is empty or not. Take
this in consideration when implementing different actions or writing test
assertions on this behavior for your controllers.

```ruby
def create
  @widget = Widget.new(widget_params)
  @widget.errors.add(:base, :invalid)
  # `respond_with` will render the `new` template again.
  respond_with @widget
end
```

## Verifying request formats

`respond_with` will raise an `ActionController::UnknownFormat` if the request
mime type was not configured through the class level `respond_to`, but the
action will still be executed and any side effects (like creating a new record)
will still occur. To raise the `UnknownFormat` exception before your action
is invoked you can set the `verify_requested_format!` method as a `before_action`
on your controller.

```ruby
class WidgetsController < ApplicationController
  respond_to :json
  before_action :verify_requested_format!

  # POST /widgets.html won't reach the `create` action.
  def create
    widget = Widget.create(widget_params)
    respond_with widget
  end
end

```

## Examples

Want more examples ? Check out this blog posts:

* [Embracing REST with mind, body and soul](http://blog.plataformatec.com.br/2009/08/embracing-rest-with-mind-body-and-soul/)
* [Three reasons to love ActionController::Responder](http://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder/)
* [My five favorite things about Rails 3](http://www.engineyard.com/blog/2009/my-five-favorite-things-about-rails-3)

## Bugs and Feedback

If you discover any bugs or want to drop a line, feel free to create an issue on GitHub.

http://github.com/plataformatec/responders/issues

MIT License. Copyright 2009-2016 Plataformatec. http://plataformatec.com.br
