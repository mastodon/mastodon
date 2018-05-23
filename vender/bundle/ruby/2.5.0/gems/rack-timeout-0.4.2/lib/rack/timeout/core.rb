# encoding: utf-8
require "securerandom"
require_relative "support/monotonic_time"
require_relative "support/scheduler"
require_relative "support/timeout"
require_relative "legacy"

module Rack
  class Timeout
    include Rack::Timeout::MonotonicTime # gets us the #fsecs method

    module ExceptionWithEnv # shared by the following exceptions, allows them to receive the current env
      attr :env
      def initialize(env)
        @env = env
      end
    end

    class Error < RuntimeError
      include ExceptionWithEnv
    end
    class RequestExpiryError  < Error; end    # raised when a request is dropped without being given a chance to run (because too old)
    class RequestTimeoutError < Error; end    # raised when a request has run for too long
    class RequestTimeoutException < Exception # This is first raised to help prevent an application from inadvertently catching the above. It's then caught by rack-timeout and replaced with RequestTimeoutError to bubble up to wrapping middlewares and the web server
      include ExceptionWithEnv
    end

    RequestDetails = Struct.new(
      :id,        # a unique identifier for the request. informative-only.
      :wait,      # seconds the request spent in the web server before being serviced by rack
      :service,   # time rack spent processing the request (updated ~ every second)
      :timeout,   # the actual computed timeout to be used for this request
      :state,     # the request's current state, see VALID_STATES below
    ) {
      def ms(k)   # helper method used for formatting values in milliseconds
        "%.fms" % (self[k] * 1000) if self[k]
      end
    }
    VALID_STATES = [
      :expired,   # The request was too old by the time it reached rack (see wait_timeout, wait_overtime)
      :ready,     # We're about to start processing this request
      :active,    # This request is currently being handled
      :timed_out, # This request has run for too long and we're raising a timeout error in it
      :completed, # We're done with this request (also set after having timed out a request)
      ]
    ENV_INFO_KEY = "rack-timeout.info" # key under which each request's RequestDetails instance is stored in its env.

    # helper methods to read timeout properties. Ensure they're always positive numbers or false. When set to false (or 0), their behaviour is disabled.
    def read_timeout_property value, default
      case value
      when nil   ; default
      when false ; false
      when 0     ; false
      else
        value.is_a?(Numeric) && value > 0 or raise ArgumentError, "value #{value.inspect} should be false, zero, or a positive number."
        value
      end
    end

    attr_reader \
      :service_timeout,   # How long the application can take to complete handling the request once it's passed down to it.
      :wait_timeout,      # How long the request is allowed to have waited before reaching rack. If exceeded, the request is 'expired', i.e. dropped entirely without being passed down to the application.
      :wait_overtime,     # Additional time over @wait_timeout for requests with a body, like POST requests. These may take longer to be received by the server before being passed down to the application, but should not be expired.
      :service_past_wait  # when false, reduces the request's computed timeout from the service_timeout value if the complete request lifetime (wait + service) would have been longer than wait_timeout (+ wait_overtime when applicable). When true, always uses the service_timeout value. we default to false under the assumption that the router would drop a request that's not responded within wait_timeout, thus being there no point in servicing beyond seconds_service_left (see code further down) up until service_timeout.

    def initialize(app, service_timeout:nil, wait_timeout:nil, wait_overtime:nil, service_past_wait:false)
      @service_timeout   = read_timeout_property service_timeout, 15
      @wait_timeout      = read_timeout_property wait_timeout,    30
      @wait_overtime     = read_timeout_property wait_overtime,   60
      @service_past_wait = service_past_wait
      @app = app
    end


    RT = self # shorthand reference
    def call(env)
      info      = (env[ENV_INFO_KEY] ||= RequestDetails.new)
      info.id ||= env["HTTP_X_REQUEST_ID"] || SecureRandom.hex

      time_started_service = Time.now                      # The wall time the request started being processed by rack
      ts_started_service   = fsecs                         # The monotonic time the request started being processed by rack
      time_started_wait    = RT._read_x_request_start(env) # The time the request was initially received by the web server (if available)
      effective_overtime   = (wait_overtime && RT._request_has_body?(env)) ? wait_overtime : 0 # additional wait timeout (if set and applicable)
      seconds_service_left = nil

      # if X-Request-Start is present and wait_timeout is set, expire requests older than wait_timeout (+wait_overtime when applicable)
      if time_started_wait && wait_timeout
        seconds_waited          = time_started_service - time_started_wait # how long it took between the web server first receiving the request and rack being able to handle it
        seconds_waited          = 0 if seconds_waited < 0                  # make up for potential time drift between the routing server and the application server
        final_wait_timeout      = wait_timeout + effective_overtime        # how long the request will be allowed to have waited
        seconds_service_left    = final_wait_timeout - seconds_waited      # first calculation of service timeout (relevant if request doesn't get expired, may be overriden later)
        info.wait, info.timeout = seconds_waited, final_wait_timeout       # updating the info properties; info.timeout will be the wait timeout at this point
        if seconds_service_left <= 0 # expire requests that have waited for too long in the queue (as they are assumed to have been dropped by the web server / routing layer at this point)
          RT._set_state! env, :expired
          raise RequestExpiryError.new(env), "Request older than #{info.ms(:timeout)}."
        end
      end

      # pass request through if service_timeout is false (i.e., don't time it out at all.)
      return @app.call(env) unless service_timeout

      # compute actual timeout to be used for this request; if service_past_wait is true, this is just service_timeout. If false (the default), and wait time was determined, we'll use the shortest value between seconds_service_left and service_timeout. See comment above at service_past_wait for justification.
      info.timeout = service_timeout # nice and simple, when service_past_wait is true, not so much otherwise:
      info.timeout = seconds_service_left if !service_past_wait && seconds_service_left && seconds_service_left > 0 && seconds_service_left < service_timeout

      RT._set_state! env, :ready                            # we're good to go, but have done nothing yet

      heartbeat_event = nil                                 # init var so it's in scope for following proc
      register_state_change = ->(status = :active) {        # updates service time and state; will run every second
        heartbeat_event.cancel! if status != :active        # if the request is no longer active we should stop updating every second
        info.service = fsecs - ts_started_service           # update service time
        RT._set_state! env, status                          # update status
      }
      heartbeat_event = RT::Scheduler.run_every(1) { register_state_change.call :active }  # start updating every second while active; if log level is debug, this will log every sec

      timeout = RT::Scheduler::Timeout.new do |app_thread|  # creates a timeout instance responsible for timing out the request. the given block runs if timed out
        register_state_change.call :timed_out
        app_thread.raise(RequestTimeoutException.new(env), "Request #{"waited #{info.ms(:wait)}, then " if info.wait}ran for longer than #{info.ms(:timeout)}")
      end

      response = timeout.timeout(info.timeout) do           # perform request with timeout
        begin  @app.call(env)                               # boom, send request down the middleware chain
        rescue RequestTimeoutException => e                 # will actually hardly ever get to this point because frameworks tend to catch this. see README for more
          raise RequestTimeoutError.new(env), e.message, e.backtrace  # but in case it does get here, re-raise RequestTimeoutException as RequestTimeoutError
        ensure
          register_state_change.call :completed
        end
      end

      response
    end

    ### following methods are used internally (called by instances, so can't be private. _ marker should discourage people from calling them)

    # X-Request-Start contains the time the request was first seen by the server. Format varies wildly amongst servers, yay!
    #   - nginx gives the time since epoch as seconds.milliseconds[1]. New Relic documentation recommends preceding it with t=[2], so might as well detect it.
    #   - Heroku gives the time since epoch in milliseconds. [3]
    #   - Apache uses t=microseconds[4], so we're not even going there.
    #
    # The sane way to handle this would be by knowing the server being used, instead let's just hack around with regular expressions and ignore apache entirely.
    # [1]: http://nginx.org/en/docs/http/ngx_http_log_module.html#var_msec
    # [2]: https://docs.newrelic.com/docs/apm/other-features/request-queueing/request-queue-server-configuration-examples#nginx
    # [3]: https://devcenter.heroku.com/articles/http-routing#heroku-headers
    # [4]: http://httpd.apache.org/docs/current/mod/mod_headers.html#header
    #
    # This is a code extraction for readability, this method is only called from a single point.
    RX_NGINX_X_REQUEST_START  = /^(?:t=)?(\d+)\.(\d{3})$/
    RX_HEROKU_X_REQUEST_START = /^(\d+)$/
    def self._read_x_request_start(env)
      return unless s = env["HTTP_X_REQUEST_START"]
      return unless m = s.match(RX_HEROKU_X_REQUEST_START) || s.match(RX_NGINX_X_REQUEST_START)
      Time.at(m[1,2].join.to_f / 1000)
    end

    # This method determines if a body is present. requests with a body (generally POST, PUT) can have a lengthy body which may have taken a while to be received by the web server, inflating their computed wait time. This in turn could lead to unwanted expirations. See wait_overtime property as a way to overcome those.
    # This is a code extraction for readability, this method is only called from a single point.
    def self._request_has_body?(env)
      return true  if env["HTTP_TRANSFER_ENCODING"] == "chunked"
      return false if env["CONTENT_LENGTH"].nil?
      return false if env["CONTENT_LENGTH"].to_i.zero?
      true
    end

    def self._set_state!(env, state)
      raise "Invalid state: #{state.inspect}" unless VALID_STATES.include? state
      env[ENV_INFO_KEY].state = state
      notify_state_change_observers(env)
    end

    ### state change notification-related methods
    @state_change_observers = {}

    # Registers a block to be called back when a request changes state in rack-timeout. The block will receive the request's env.
    #
    # `id` is anything that uniquely identifies this particular callback, mostly so it may be removed via `unregister_state_change_observer`.
    def self.register_state_change_observer(id, &callback)
      raise RuntimeError, "An observer with the id #{id.inspect} is already set." if @state_change_observers.key? id
      raise ArgumentError, "A callback block is required." unless callback
      @state_change_observers[id] = callback
    end

    # Removes the observer with the given id
    def self.unregister_state_change_observer(id)
      @state_change_observers.delete(id)
    end

    private
    # Sends out the notifications. Called internally at the end of `_set_state!`
    def self.notify_state_change_observers(env)
      @state_change_observers.values.each { |observer| observer.call(env) }
    end

  end
end
