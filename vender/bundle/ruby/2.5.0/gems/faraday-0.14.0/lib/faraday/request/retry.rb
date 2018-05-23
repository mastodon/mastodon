module Faraday
  # Catches exceptions and retries each request a limited number of times.
  #
  # By default, it retries 2 times and handles only timeout exceptions. It can
  # be configured with an arbitrary number of retries, a list of exceptions to
  # handle, a retry interval, a percentage of randomness to add to the retry
  # interval, and a backoff factor.
  #
  # Examples
  #
  #   Faraday.new do |conn|
  #     conn.request :retry, max: 2, interval: 0.05,
  #                          interval_randomness: 0.5, backoff_factor: 2,
  #                          exceptions: [CustomException, 'Timeout::Error']
  #     conn.adapter ...
  #   end
  #
  # This example will result in a first interval that is random between 0.05 and 0.075 and a second
  # interval that is random between 0.1 and 0.15
  #
  class Request::Retry < Faraday::Middleware

    IDEMPOTENT_METHODS = [:delete, :get, :head, :options, :put]

    class Options < Faraday::Options.new(:max, :interval, :max_interval, :interval_randomness,
                                         :backoff_factor, :exceptions, :methods, :retry_if)
      DEFAULT_CHECK = lambda { |env,exception| false }

      def self.from(value)
        if Integer === value
          new(value)
        else
          super(value)
        end
      end

      def max
        (self[:max] ||= 2).to_i
      end

      def interval
        (self[:interval] ||= 0).to_f
      end

      def max_interval
        (self[:max_interval] ||= Float::MAX).to_f
      end

      def interval_randomness
        (self[:interval_randomness] ||= 0).to_f
      end

      def backoff_factor
        (self[:backoff_factor] ||= 1).to_f
      end

      def exceptions
        Array(self[:exceptions] ||= [Errno::ETIMEDOUT, 'Timeout::Error',
                                     Error::TimeoutError])
      end

      def methods
        Array(self[:methods] ||= IDEMPOTENT_METHODS)
      end

      def retry_if
        self[:retry_if] ||= DEFAULT_CHECK
      end

    end

    # Public: Initialize middleware
    #
    # Options:
    # max                 - Maximum number of retries (default: 2)
    # interval            - Pause in seconds between retries (default: 0)
    # interval_randomness - The maximum random interval amount expressed
    #                       as a float between 0 and 1 to use in addition to the
    #                       interval. (default: 0)
    # max_interval        - An upper limit for the interval (default: Float::MAX)
    # backoff_factor      - The amount to multiple each successive retry's
    #                       interval amount by in order to provide backoff
    #                       (default: 1)
    # exceptions          - The list of exceptions to handle. Exceptions can be
    #                       given as Class, Module, or String. (default:
    #                       [Errno::ETIMEDOUT, Timeout::Error,
    #                       Error::TimeoutError])
    # methods             - A list of HTTP methods to retry without calling retry_if.  Pass
    #                       an empty Array to call retry_if for all exceptions.
    #                       (defaults to the idempotent HTTP methods in IDEMPOTENT_METHODS)
    # retry_if            - block that will receive the env object and the exception raised
    #                       and should decide if the code should retry still the action or
    #                       not independent of the retry count. This would be useful
    #                       if the exception produced is non-recoverable or if the
    #                       the HTTP method called is not idempotent.
    #                       (defaults to return false)
    def initialize(app, options = nil)
      super(app)
      @options = Options.from(options)
      @errmatch = build_exception_matcher(@options.exceptions)
    end

    def sleep_amount(retries)
      retry_index = @options.max - retries
      current_interval = @options.interval * (@options.backoff_factor ** retry_index)
      current_interval = [current_interval, @options.max_interval].min
      random_interval  = rand * @options.interval_randomness.to_f * @options.interval
      current_interval + random_interval
    end

    def call(env)
      retries = @options.max
      request_body = env[:body]
      begin
        env[:body] = request_body # after failure env[:body] is set to the response body
        @app.call(env)
      rescue @errmatch => exception
        if retries > 0 && retry_request?(env, exception)
          retries -= 1
          rewind_files(request_body)
          sleep sleep_amount(retries + 1)
          retry
        end
        raise
      end
    end

    # Private: construct an exception matcher object.
    #
    # An exception matcher for the rescue clause can usually be any object that
    # responds to `===`, but for Ruby 1.8 it has to be a Class or Module.
    def build_exception_matcher(exceptions)
      matcher = Module.new
      (class << matcher; self; end).class_eval do
        define_method(:===) do |error|
          exceptions.any? do |ex|
            if ex.is_a? Module
              error.is_a? ex
            else
              error.class.to_s == ex.to_s
            end
          end
        end
      end
      matcher
    end

    private

    def retry_request?(env, exception)
      @options.methods.include?(env[:method]) || @options.retry_if.call(env, exception)
    end

    def rewind_files(body)
      return unless body.is_a?(Hash)
      body.each do |_, value|
        if value.is_a? UploadIO
          value.rewind
        end
      end
    end

  end
end
