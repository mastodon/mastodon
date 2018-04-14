# frozen_string_literal: true

module Devise
  module Test
    # `Devise::Test::ControllerHelpers` provides a facility to test controllers
    # in isolation when using `ActionController::TestCase` allowing you to
    # quickly sign_in or sign_out a user. Do not use
    # `Devise::Test::ControllerHelpers` in integration tests.
    #
    # Examples
    #
    #  class PostsTest < ActionController::TestCase
    #    include Devise::Test::ControllerHelpers
    #
    #    test 'authenticated users can GET index' do
    #      sign_in users(:bob)
    #
    #      get :index
    #      assert_response :success
    #    end
    #  end
    #
    # Important: you should not test Warden specific behavior (like callbacks)
    # using `Devise::Test::ControllerHelpers` since it is a stub of the actual
    # behavior. Such callbacks should be tested in your integration suite instead.
    module ControllerHelpers
      extend ActiveSupport::Concern

      included do
        setup :setup_controller_for_warden, :warden
      end

      # Override process to consider warden.
      def process(*)
        _catch_warden { super }

        @response
      end

      # We need to set up the environment variables and the response in the controller.
      def setup_controller_for_warden #:nodoc:
        @request.env['action_controller.instance'] = @controller
      end

      # Quick access to Warden::Proxy.
      def warden #:nodoc:
        @request.env['warden'] ||= begin
          manager = Warden::Manager.new(nil) do |config|
            config.merge! Devise.warden_config
          end
          Warden::Proxy.new(@request.env, manager)
        end
      end

      # sign_in a given resource by storing its keys in the session.
      # This method bypass any warden authentication callback.
      #
      # * +resource+ - The resource that should be authenticated
      # * +scope+    - An optional +Symbol+ with the scope where the resource
      #                should be signed in with.
      # Examples:
      #
      # sign_in users(:alice)
      # sign_in users(:alice), scope: :admin
      def sign_in(resource, deprecated = nil, scope: nil)
        if deprecated.present?
          scope = resource
          resource = deprecated

          ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
            [Devise] sign_in(:#{scope}, resource) on controller tests is deprecated and will be removed from Devise.
            Please use sign_in(resource, scope: :#{scope}) instead.
          DEPRECATION
        end

        scope ||= Devise::Mapping.find_scope!(resource)

        warden.instance_variable_get(:@users).delete(scope)
        warden.session_serializer.store(resource, scope)
      end

      # Sign out a given resource or scope by calling logout on Warden.
      # This method bypass any warden logout callback.
      #
      # Examples:
      #
      #   sign_out :user     # sign_out(scope)
      #   sign_out @user     # sign_out(resource)
      #
      def sign_out(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        @controller.instance_variable_set(:"@current_#{scope}", nil)
        user = warden.instance_variable_get(:@users).delete(scope)
        warden.session_serializer.delete(scope, user)
      end

      protected

      # Catch warden continuations and handle like the middleware would.
      # Returns nil when interrupted, otherwise the normal result of the block.
      def _catch_warden(&block)
        result = catch(:warden, &block)

        env = @controller.request.env

        result ||= {}

        # Set the response. In production, the rack result is returned
        # from Warden::Manager#call, which the following is modelled on.
        case result
        when Array
          if result.first == 401 && intercept_401?(env) # does this happen during testing?
            _process_unauthenticated(env)
          else
            result
          end
        when Hash
          _process_unauthenticated(env, result)
        else
          result
        end
      end

      def _process_unauthenticated(env, options = {})
        options[:action] ||= :unauthenticated
        proxy = request.env['warden']
        result = options[:result] || proxy.result

        ret = case result
        when :redirect
          body = proxy.message || "You are being redirected to #{proxy.headers['Location']}"
          [proxy.status, proxy.headers, [body]]
        when :custom
          proxy.custom_response
        else
          request.env["PATH_INFO"] = "/#{options[:action]}"
          request.env["warden.options"] = options
          Warden::Manager._run_callbacks(:before_failure, env, options)

          status, headers, response = Devise.warden_config[:failure_app].call(env).to_a
          @controller.response.headers.merge!(headers)
          @controller.response.content_type = headers["Content-Type"] unless Rails.version.start_with?('5')
          @controller.status = status
          @controller.response.body = response.body
          nil # causes process return @response
        end

        # ensure that the controller response is set up. In production, this is
        # not necessary since warden returns the results to rack. However, at
        # testing time, we want the response to be available to the testing
        # framework to verify what would be returned to rack.
        if ret.is_a?(Array)
          status, headers, body = *ret
          # ensure the controller response is set to our response.
          @controller.response ||= @response
          @response.status = status
          @response.headers.merge!(headers)
          @response.body = body
        end

        ret
      end
    end
  end
end
