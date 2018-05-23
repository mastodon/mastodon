###
# This is an example of how to use Rack-Proxy in a Rails application.
#  
# Setup:
# 1. rails new test_app 
# 2. cd test_app
# 3. install Rack-Proxy in `Gemfile`
#    a. `gem 'rack-proxy', '~> 0.6.3'`
# 4. install gem: `bundle install`
# 5. create `config/initializers/proxy.rb` adding this line `require 'rack_proxy_examples/example_service_proxy'`
# 6. run: `SERVICE_URL=http://guides.rubyonrails.org rails server`
# 7. open in browser: `http://localhost:3000/example_service`
#
###
ENV['SERVICE_URL'] ||= 'http://guides.rubyonrails.org'

class ExampleServiceProxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    # use rack proxy for anything hitting our host app at /example_service
    if request.path =~ %r{^/example_service}
        backend = URI(ENV['SERVICE_URL'])
        # most backends required host set properly, but rack-proxy doesn't set this for you automatically
        # even when a backend host is passed in via the options
        env["HTTP_HOST"] = backend.host

        # This is the only path that needs to be set currently on Rails 5 & greater
        env['PATH_INFO'] = ENV['SERVICE_PATH'] || '/configuring.html'
        
        # don't send your sites cookies to target service, unless it is a trusted internal service that can parse all your cookies
        env['HTTP_COOKIE'] = ''
        super(env)
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.use ExampleServiceProxy, backend: ENV['SERVICE_URL'], streaming: false
