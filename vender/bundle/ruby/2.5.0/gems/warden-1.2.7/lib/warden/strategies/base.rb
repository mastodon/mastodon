# frozen_string_literal: true
# encoding: utf-8
module Warden
  module Strategies
    # A strategy is a place where you can put logic related to authentication. Any strategy inherits
    # from Warden::Strategies::Base.
    #
    # The Warden::Strategies.add method is a simple way to provide custom strategies.
    # You _must_ declare an @authenticate!@ method.
    # You _may_ provide a @valid?@ method.
    # The valid method should return true or false depending on if the strategy is a valid one for the request.
    #
    # The parameters for Warden::Strategies.add method are:
    #   <label: Symbol> The label is the name given to a strategy.  Use the label to refer to the strategy when authenticating
    #   <strategy: Class|nil> The optional strategy argument if set _must_ be a class that inherits from Warden::Strategies::Base and _must_
    #                         implement an @authenticate!@ method
    #   <block> The block acts as a convenient way to declare your strategy.  Inside is the class definition of a strategy.
    #
    # Examples:
    #
    #   Block Declared Strategy:
    #    Warden::Strategies.add(:foo) do
    #      def authenticate!
    #        # authentication logic
    #      end
    #    end
    #
    #    Class Declared Strategy:
    #      Warden::Strategies.add(:foo, MyStrategy)
    #
    class Base
      # :api: public
      attr_accessor :user, :message

      # :api: private
      attr_accessor :result, :custom_response

      # :api: public
      attr_reader :env, :scope, :status

      include ::Warden::Mixins::Common

      # :api: private
      def initialize(env, scope=nil) # :nodoc:
        @env, @scope = env, scope
        @status, @headers = nil, {}
        @halted, @performed = false, false
      end

      # The method that is called from above. This method calls the underlying authenticate! method
      # :api: private
      def _run! # :nodoc:
        @performed = true
        authenticate!
        self
      end

      # Returns if this strategy was already performed.
      # :api: private
      def performed? #:nodoc:
        @performed
      end

      # Marks this strategy as not performed.
      # :api: private
      def clear!
        @performed = false
      end

      # Acts as a guarding method for the strategy.
      # If #valid? responds false, the strategy will not be executed
      # Overwrite with your own logic
      # :api: overwritable
      def valid?; true; end

      # Provides access to the headers hash for setting custom headers
      # :api: public
      def headers(header = {})
        @headers ||= {}
        @headers.merge! header
        @headers
      end

      # Access to the errors object.
      # :api: public
      def errors
        @env['warden'].errors
      end

      # Cause the processing of the strategies to stop and cascade no further
      # :api: public
      def halt!
        @halted = true
      end

      # Checks to see if a strategy was halted
      # :api: public
      def halted?
        !!@halted
      end

      # Checks to see if a strategy should result in a permanent login
      # :api: public
      def store?
        true
      end

      # A simple method to return from authenticate! if you want to ignore this strategy
      # :api: public
      def pass; end

      # Returns true only if the result is a success and a user was assigned.
      def successful?
        @result == :success && !user.nil?
      end

      # Whenever you want to provide a user object as "authenticated" use the +success!+ method.
      # This will halt the strategy, and set the user in the appropriate scope.
      # It is the "login" method
      #
      # Parameters:
      #   user - The user object to login.  This object can be anything you have setup to serialize in and out of the session
      #
      # :api: public
      def success!(user, message = nil)
        halt!
        @user = user
        @message = message
        @result = :success
      end

      # This causes the strategy to fail.  It does not throw an :warden symbol to drop the request out to the failure application
      # You must throw an :warden symbol somewhere in the application to enforce this
      # Halts the strategies so that this is the last strategy checked
      # :api: public
      def fail!(message = "Failed to Login")
        halt!
        @message = message
        @result = :failure
      end

      # Causes the strategy to fail, but not halt.  The strategies will cascade after this failure and warden will check the next strategy.  The last strategy to fail will have it's message displayed.
      # :api: public
      def fail(message = "Failed to Login")
        @message = message
        @result = :failure
      end

      # Causes the authentication to redirect.  An :warden symbol must be thrown to actually execute this redirect
      #
      # Parameters:
      #  url <String> - The string representing the URL to be redirected to
      #  params <Hash> - Any parameters to encode into the URL
      #  opts <Hash> - Any options to redirect with.
      #    available options: permanent => (true || false)
      #
      # :api: public
      def redirect!(url, params = {}, opts = {})
        halt!
        @status = opts[:permanent] ? 301 : 302
        headers["Location"] = url.dup
        headers["Location"] << "?" << Rack::Utils.build_query(params) unless params.empty?
        headers["Content-Type"] = opts[:content_type] || 'text/plain'

        @message = opts[:message] || "You are being redirected to #{headers["Location"]}"
        @result = :redirect

        headers["Location"]
      end

      # Return a custom rack array.  You must throw an :warden symbol to activate this
      # :api: public
      def custom!(response)
        halt!
        @custom_response = response
        @result = :custom
      end

    end # Base
  end # Strategies
end # Warden
