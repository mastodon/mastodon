require 'thread'
require 'rack/body_proxy'

module Rack
  # Rack::Lock locks every request inside a mutex, so that every request
  # will effectively be executed synchronously.
  class Lock
    def initialize(app, mutex = Mutex.new)
      @app, @mutex = app, mutex
    end

    def call(env)
      @mutex.lock
      @env = env
      @old_rack_multithread = env[RACK_MULTITHREAD]
      begin
        response = @app.call(env.merge!(RACK_MULTITHREAD => false))
        returned = response << BodyProxy.new(response.pop) { unlock }
      ensure
        unlock unless returned
      end
    end

    private

    def unlock
      @mutex.unlock
      @env[RACK_MULTITHREAD] = @old_rack_multithread
    end
  end
end
