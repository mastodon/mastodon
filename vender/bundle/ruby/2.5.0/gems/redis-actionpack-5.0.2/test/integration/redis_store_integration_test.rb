require 'test_helper'

class RedisStoreIntegrationTest < ::ActionDispatch::IntegrationTest
  SessionKey = '_session_id'
  SessionSecret = 'b3c631c314c0bbca50c1b2843150fe33'

  test "reads the data" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id'].present?

      get '/get_session_value'
      assert_response :success
      assert_equal response.body, 'foo: "bar"'
    end
  end

  test "should get nil session value" do
    with_test_route_set do
      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
    end
  end

  test "should delete the data after session reset" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id'].present?
      session_cookie = cookies.send(:hash_for)['_session_id']

      get '/call_reset_session'
      assert_response :success
      assert !headers['Set-Cookie'].blank?

      cookies << session_cookie

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
    end
  end

  test "should set a non-secure cookie by default" do
    with_test_route_set do
      https!

      get '/set_session_value'
      assert_response :success

      cookie = cookies.instance_variable_get('@cookies').first

      assert !cookie.secure?
    end
  end

  test "should set a secure cookie when the 'secure' option is set" do
    with_test_route_set(secure: true) do
      https!

      get '/set_session_value'
      assert_response :success

      cookie = cookies.instance_variable_get('@cookies').first

      assert cookie.secure?
    end
  end

  test "should set a http-only cookie by default" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success

      cookie = cookies.instance_variable_get('@cookies').first
      options = cookie.instance_variable_get('@options')

      assert options.key?('HttpOnly')
    end
  end

  test "should set a non-http-only cookie when the 'httponlty' option is set to false" do
    with_test_route_set(httponly: false) do
      get '/set_session_value'
      assert_response :success

      cookie = cookies.instance_variable_get('@cookies').first
      options = cookie.instance_variable_get('@options')

      assert !options.key?('HttpOnly')
    end
  end

  test "should not send cookies on write, not read" do
    with_test_route_set do
      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
      assert cookies['_session_id'].nil?
    end
  end

  test "should set session value after session reset" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id'].present?
      session_id = cookies['_session_id']

      get '/call_reset_session'
      assert_response :success
      assert !headers['Set-Cookie'].blank?

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body

      get '/get_session_id'
      assert_response :success
      assert(response.body != session_id)
    end
  end

  test "should be able to read session id without accessing the session hash" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id'].present?
      session_id = cookies['_session_id']

      get '/get_session_id'
      assert_response :success
      assert_equal response.body, session_id
    end
  end

  test "should auto-load unloaded class" do
    with_test_route_set do
      with_autoload_path "session_autoload_test" do
        get '/set_serialized_session_value'
        assert_response :success
        assert cookies['_session_id'].present?
      end

      with_autoload_path "session_autoload_test" do
        get '/get_session_id'
        assert_response :success
      end

      with_autoload_path "session_autoload_test" do
        get '/get_session_value'
        assert_response :success
        assert_equal response.body, 'foo: #<SessionAutoloadTest::Foo bar:"baz">'
      end
    end
  end

  test "should not resend the cookie again if session_id cookie is already exists" do
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id'].present?

      get '/get_session_value'
      assert_response :success
      assert headers['Set-Cookie'].nil?
    end
  end

  test "should prevent session fixation" do
    with_test_route_set do
      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
      session_id = cookies['_session_id']

      reset!

      get '/set_session_value', headers: { _session_id: session_id }
      assert_response :success
      assert(cookies['_session_id'] != session_id)
    end
  end

  test "should write the data with expiration time" do
    with_test_route_set do
      get '/set_session_value_with_expiry'
      assert_response :success

      get '/get_session_value'
      assert_response :success
      assert_equal response.body, 'foo: "bar"'

      sleep 1

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
    end
  end

  test "session store with explicit domain" do
    with_test_route_set(:domain => "example.es") do
      get '/set_session_value'
      assert_match(/domain=example\.es/, headers['Set-Cookie'])
      headers['Set-Cookie']
    end
  end

  test "session store without domain" do
    with_test_route_set do
      get '/set_session_value'
      assert_no_match(/domain\=/, headers['Set-Cookie'])
    end
  end

  test "session store with nil domain" do
    with_test_route_set(:domain => nil) do
      get '/set_session_value'
      assert_no_match(/domain\=/, headers['Set-Cookie'])
    end
  end

  test "session store with all domains" do
    with_test_route_set(:domain => :all) do
      get '/set_session_value'
      assert_match(/domain=\.example\.com/, headers['Set-Cookie'])
    end
  end

  private

    # from actionpack/test/abstract_unit.rb
    class RoutedRackApp
      attr_reader :routes
      def initialize(routes, &blk)
        @routes = routes
        @stack = ActionDispatch::MiddlewareStack.new(&blk).build(@routes)
      end
      def call(env)
        @stack.call(env)
      end
    end

    # from actionpack/test/abstract_unit.rb
    def self.build_app(routes = nil)
      RoutedRackApp.new(routes || ActionDispatch::Routing::RouteSet.new) do |middleware|
        middleware.use ActionDispatch::DebugExceptions
        middleware.use ActionDispatch::Callbacks
        # middleware.use ActionDispatch::ParamsParser
        middleware.use ActionDispatch::Cookies
        middleware.use ActionDispatch::Flash
        middleware.use Rack::Head
        yield(middleware) if block_given?
      end
    end

    # from actionpack/test/dispatch/session/cookie_store_test.rb
    def with_test_route_set(options = {})
      with_routing do |set|
        set.draw do
          get :no_session_access,             to: 'test#no_session_access'
          get :set_session_value,             to: 'test#set_session_value'
          get :set_session_value_with_expiry, to: 'test#set_session_value_with_expiry'
          get :set_serialized_session_value,  to: 'test#set_serialized_session_value'
          get :get_session_value,             to: 'test#get_session_value'
          get :get_session_id,                to: 'test#get_session_id'
          get :call_reset_session,            to: 'test#call_reset_session'
        end
        options = { :key => SessionKey }.merge!(options)
        @app = self.class.build_app(set) do |middleware|
          middleware.use ActionDispatch::Session::RedisStore, options
        end
        yield
      end
    end
end
