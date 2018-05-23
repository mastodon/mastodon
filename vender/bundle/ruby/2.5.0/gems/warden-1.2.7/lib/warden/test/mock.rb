# frozen_string_literal: true
# encoding: utf-8

require 'rack'

module Warden
  module Test
    # A mock of an application to get a Warden object to test on
    # Note: During the teardown phase of your specs you should include: Warden.test_reset!
    module Mock
      def self.included(base)
        ::Warden.test_mode!
      end

      # A helper method that provides the warden object by mocking the env variable.
      # @api public
      def warden
        @warden ||= begin
          env['warden']
        end
      end

      private

      def env
        @env ||= begin
          request = Rack::MockRequest.env_for(
            "/?#{Rack::Utils.build_query({})}",
            { 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => 'GET' }
          )
          app.call(request)

          request
        end
      end

      def app
        @app ||= begin
          opts = {
            failure_app: lambda {
              [401, { 'Content-Type' => 'text/plain' }, ['You Fail!']]
            },
            default_strategies: :password,
            default_serializers: :session
          }
          Rack::Builder.new do
            use Warden::Test::Mock::Session
            use Warden::Manager, opts, &proc {}
            run lambda { |e|
              [200, { 'Content-Type' => 'text/plain' }, ['You Win']]
            }
          end
        end
      end

      class Session
        attr_accessor :app
        def initialize(app,configs = {})
          @app = app
        end

        def call(e)
          e['rack.session'] ||= {}
          @app.call(e)
        end
      end # session
    end
  end
end
