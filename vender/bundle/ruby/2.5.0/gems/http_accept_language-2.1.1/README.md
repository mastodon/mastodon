# HttpAcceptLanguage [![Build Status](https://travis-ci.org/iain/http_accept_language.svg?branch=master)](https://travis-ci.org/iain/http_accept_language)

A gem which helps you detect the users preferred language, as sent by the "Accept-Language" HTTP header.

The algorithm is based on [RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html), with one exception:
when a user requests "en-US" and "en" is an available language, "en" is deemed compatible with "en-US".
The RFC specifies that the requested language must either exactly match the available language or must exactly match a prefix of the available language. This means that when the user requests "en" and "en-US" is available, "en-US" would be compatible, but not the other way around. This is usually not what you're looking for.

Since version 2.0, this gem is Rack middleware.

## Example

The `http_accept_language` method is available in any controller:

```ruby
class SomeController < ApplicationController
  def some_action
    http_accept_language.user_preferred_languages # => %w(nl-NL nl-BE nl en-US en)
    available = %w(en en-US nl-BE)
    http_accept_language.preferred_language_from(available) # => 'nl-BE'

    http_accept_language.user_preferred_languages # => %w(en-GB)
    available = %w(en-US)
    http_accept_language.compatible_language_from(available) # => 'en-US'

    http_accept_language.user_preferred_languages # => %w(nl-NL nl-BE nl en-US en)
    available = %w(en nl de) # This could be from I18n.available_locales
    http_accept_language.preferred_language_from(available) # => 'nl'
  end
end
```

You can easily set the locale used for i18n in a before-filter:

```ruby
class SomeController < ApplicationController
  before_filter :set_locale

  private
    def set_locale
      I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
    end
end
```

If you want to enable this behavior by default in your controllers, you can just include the provided concern:

```ruby
class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale

#...
end
```

Then set available locales in `config/application.rb`:

```ruby
config.i18n.available_locales = %w(en nl de fr)
```

To use the middleware in any Rack application, simply add the middleware:

``` ruby
require 'http_accept_language'
use HttpAcceptLanguage::Middleware
run YourAwesomeApp
```

Then you can access it from `env`:

``` ruby
class YourAwesomeApp

  def initialize(app)
    @app = app
  end

  def call(env)
    available = %w(en en-US nl-BE)
    language = env.http_accept_language.preferred_language_from(available)

    [200, {}, ["Oh, you speak #{language}!"]]
  end

end
```

## Available methods

* **user_preferred_languages**:
  Returns a sorted array based on user preference in HTTP_ACCEPT_LANGUAGE, sanitized and all.
* **preferred_language_from(languages)**:
  Finds the locale specifically requested by the browser
* **compatible_language_from(languages)**:
  Returns the first of the user_preferred_languages that is compatible with the available locales.
  Ignores region.
* **sanitize_available_locales(languages)**:
  Returns a supplied list of available locals without any extra application info
  that may be attached to the locale for storage in the application.
* **language_region_compatible_from(languages)**:
  Returns the first of the user preferred languages that is
  also found in available languages.  Finds best fit by matching on
  primary language first and secondarily on region.  If no matching region is
  found, return the first language in the group matching that primary language.

## Installation

### Without Bundler

Install the gem `http_accept_language`

### With Bundler

Add the gem to your Gemfile:

``` ruby
gem 'http_accept_language'
```

Run `bundle install` to install it.

---

Released under the MIT license
