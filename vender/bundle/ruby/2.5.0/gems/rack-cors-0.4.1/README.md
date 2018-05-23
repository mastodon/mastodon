# Rack CORS Middleware [![Build Status](https://travis-ci.org/cyu/rack-cors.svg?branch=master)](https://travis-ci.org/cyu/rack-cors)

`Rack::Cors` provides support for Cross-Origin Resource Sharing (CORS) for Rack compatible web applications.

The [CORS spec](http://www.w3.org/TR/cors/) allows web applications to make cross domain AJAX calls without using workarounds such as JSONP. See [Cross-domain Ajax with Cross-Origin Resource Sharing](http://www.nczonline.net/blog/2010/05/25/cross-domain-ajax-with-cross-origin-resource-sharing/)

## Installation

Install the gem:

`gem install rack-cors`

Or in your Gemfile:

```ruby
gem 'rack-cors', :require => 'rack/cors'
```


## Configuration

### Rails Configuration
Put something like the code below in `config/application.rb` of your Rails application. For example, this will allow GET, POST or OPTIONS requests from any origin on any resource.

```ruby
module YourApp
  class Application < Rails::Application

    # ...
    
    # Rails 3/4

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
    
    # Rails 5

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

  end
end
```
Refer to [rails 3 example](https://github.com/cyu/rack-cors/tree/master/examples/rails3) and [rails 4 example](https://github.com/cyu/rack-cors/tree/master/examples/rails4) for more details.

See The [Rails Guide to Rack](http://guides.rubyonrails.org/rails_on_rack.html) for more details on rack middlewares or watch the [railscast](http://railscasts.com/episodes/151-rack-middleware).

### Rack Configuration

NOTE: If you're running Rails, updating in `config/application.rb` should be enough.  There is no need to update `config.ru` as well.

In `config.ru`, configure `Rack::Cors` by passing a block to the `use` command:

```ruby
use Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000',
            /\Ahttp:\/\/192\.168\.0\.\d{1,3}(:\d+)?\z/
            # regular expressions can be used here

    resource '/file/list_all/', :headers => 'x-domain-token'
    resource '/file/at/*',
        :methods => [:get, :post, :delete, :put, :patch, :options, :head],
        :headers => 'x-domain-token',
        :expose  => ['Some-Custom-Response-Header'],
        :max_age => 600
        # headers to expose
  end

  allow do
    origins '*'
    resource '/public/*', :headers => :any, :methods => :get
  end
end
```

### Configuration Reference

#### Middleware Options
* **debug** (boolean):  Enables debug logging and `X-Rack-CORS` HTTP headers for debugging.
* **logger** (Object or Proc): Specify the logger to log to.  If a proc is provided, it will be called when a logger is needed.  This is helpful in cases where the logger is initialized after `Rack::Cors` is initially configured, like `Rails.logger`.

#### Origin
Origins can be specified as a string, a regular expression, or as '\*' to allow all origins.

**\*SECURITY NOTE:** Be careful when using regular expressions to not accidentally be too inclusive.  For example, the expression `/https:\/\/example\.com/` will match the domain *example.com.randomdomainname.co.uk*.  It is recommended that any regular expression be enclosed with start & end string anchors (`\A\z`).

Additionally, origins can be specified dynamically via a block of the following form:
```ruby
  origins { |source, env| true || false }
```

#### Resource
A Resource path can be specified as exact string match (`/path/to/file.txt`) or with a '\*' wildcard (`/all/files/in/*`).  A resource can take the following options:

* **methods** (string or array or `:any`): The HTTP methods allowed for the resource.
* **headers** (string or array or `:any`): The HTTP headers that will be allowed in the CORS resource request.  Use `:any` to allow for any headers in the actual request.
* **expose** (string or array): The HTTP headers in the resource response can be exposed to the client.
* **credentials** (boolean): Sets the `Access-Control-Allow-Credentials` response header.
* **max_age** (number): Sets the `Access-Control-Max-Age` response header.
* **if** (Proc): If the result of the proc is true, will process the request as a valid CORS request.
* **vary** (string or array): A list of HTTP headers to add to the 'Vary' header.


## Common Gotchas

Incorrect positioning of `Rack::Cors` in the middleware stack can produce unexpected results.  The Rails example above will put it above all middleware which should cover most issues.

Here are some common cases:

* **Serving static files.**  Insert this middleware before `ActionDispatch::Static` so that static files are served with the proper CORS headers (see note below for a caveat).  **NOTE:** that this might not work in production environments as static files are usually served from the web server (Nginx, Apache) and not the Rails container.

* **Caching in the middleware.**  Insert this middleware before `Rack::Cache` so that the proper CORS headers are written and not cached ones.

* **Authentication via Warden**  Warden will return immediately if a resource that requires authentication is accessed without authentication.  If `Warden::Manager`is in the stack before `Rack::Cors`, it will return without the correct CORS headers being applied, resulting in a failed CORS request.  Be sure to insert this middleware before 'Warden::Manager`.

To determine where to put the CORS middleware in the Rack stack, run the following command:

```bash
bundle exec rake middleware
```

In many cases, the Rack stack will be different running in production environments.  For example, the `ActionDispatch::Static` middleware will not be part of the stack if `config.serve_static_assets = false`.  You can run the following command to see what your middleware stack looks like in production:

```bash
RAILS_ENV=production bundle exec rake middleware
```
