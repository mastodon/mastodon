# frozen_string_literal: true
# encoding: utf-8
require 'warden/hooks'
require 'warden/config'

module Warden
  # The middleware for Rack Authentication
  # The middleware requires that there is a session upstream
  # The middleware injects an authentication object into
  # the rack environment hash
  class Manager
    extend Warden::Hooks

    attr_accessor :config

    # Initialize the middleware. If a block is given, a Warden::Config is yielded so you can properly
    # configure the Warden::Manager.
    # :api: public
    def initialize(app, options={})
      default_strategies = options.delete(:default_strategies)

      @app, @config = app, Warden::Config.new(options)
      @config.default_strategies(*default_strategies) if default_strategies
      yield @config if block_given?
      self
    end

    # Invoke the application guarding for throw :warden.
    # If this is downstream from another warden instance, don't do anything.
    # :api: private
    def call(env) # :nodoc:
      return @app.call(env) if env['warden'] && env['warden'].manager != self

      env['warden'] = Proxy.new(env, self)
      result = catch(:warden) do
        @app.call(env)
      end

      result ||= {}
      case result
      when Array
        handle_chain_result(result.first, result, env)
      when Hash
        process_unauthenticated(env, result)
      when Rack::Response
        handle_chain_result(result.status, result, env)
      end
    end

    # :api: private
    def _run_callbacks(*args) #:nodoc:
      self.class._run_callbacks(*args)
    end

    class << self
      # Prepares the user to serialize into the session.
      # Any object that can be serialized into the session in some way can be used as a "user" object
      # Generally however complex object should not be stored in the session.
      # If possible store only a "key" of the user object that will allow you to reconstitute it.
      #
      # You can supply different methods of serialization for different scopes by passing a scope symbol
      #
      # Example:
      #   Warden::Manager.serialize_into_session{ |user| user.id }
      #   # With Scope:
      #   Warden::Manager.serialize_into_session(:admin) { |user| user.id }
      #
      # :api: public
      def serialize_into_session(scope = nil, &block)
        method_name = scope.nil? ? :serialize : "#{scope}_serialize"
        Warden::SessionSerializer.send :define_method, method_name, &block
      end

      # Reconstitutes the user from the session.
      # Use the results of user_session_key to reconstitute the user from the session on requests after the initial login
      # You can supply different methods of de-serialization for different scopes by passing a scope symbol
      #
      # Example:
      #   Warden::Manager.serialize_from_session{ |id| User.get(id) }
      #   # With Scope:
      #   Warden::Manager.serialize_from_session(:admin) { |id| AdminUser.get(id) }
      #
      # :api: public
      def serialize_from_session(scope = nil, &block)
        method_name = scope.nil? ? :deserialize : "#{scope}_deserialize"

        if Warden::SessionSerializer.method_defined? method_name
          Warden::SessionSerializer.send :remove_method, method_name
        end

        Warden::SessionSerializer.send :define_method, method_name, &block
      end
    end

  private

    def handle_chain_result(status, result, env)
      if status == 401 && intercept_401?(env)
        process_unauthenticated(env)
      else
        result
      end
    end

    def intercept_401?(env)
      config[:intercept_401] && !env['warden'].custom_failure?
    end

    # When a request is unauthenticated, here's where the processing occurs.
    # It looks at the result of the proxy to see if it's been executed and what action to take.
    # :api: private
    def process_unauthenticated(env, options={})
      options[:action] ||= begin
        opts = config[:scope_defaults][config.default_scope] || {}
        opts[:action] || 'unauthenticated'
      end

      proxy  = env['warden']
      result = options[:result] || proxy.result

      case result
      when :redirect
        body = proxy.message || "You are being redirected to #{proxy.headers['Location']}"
        [proxy.status, proxy.headers, [body]]
      when :custom
        proxy.custom_response
      else
        options[:message] ||= proxy.message
        call_failure_app(env, options)
      end
    end

    # Calls the failure app.
    # The before_failure hooks are run on each failure
    # :api: private
    def call_failure_app(env, options = {})
      if config.failure_app
        options.merge!(:attempted_path => ::Rack::Request.new(env).fullpath)
        env["PATH_INFO"] = "/#{options[:action]}"
        env["warden.options"] = options

        _run_callbacks(:before_failure, env, options)
        config.failure_app.call(env).to_a
      else
        raise "No Failure App provided"
      end
    end # call_failure_app
  end
end # Warden
