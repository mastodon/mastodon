# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class FailureTest < ActiveSupport::TestCase
  class RootFailureApp < Devise::FailureApp
    def fake_app
      Object.new
    end
  end

  class FailureWithSubdomain < RootFailureApp
    routes = ActionDispatch::Routing::RouteSet.new

    routes.draw do
      scope subdomain: 'sub' do
        root to: 'foo#bar'
      end
    end

    include routes.url_helpers
  end

  class FailureWithI18nOptions < Devise::FailureApp
    def i18n_options(options)
      options.merge(name: 'Steve')
    end
  end

  class FakeEngineApp < Devise::FailureApp
    class FakeEngine
      def new_user_on_engine_session_url _
        '/user_on_engines/sign_in'
      end
    end

    def main_app
      raise 'main_app router called instead of fake_engine'
    end

    def fake_engine
      @fake_engine ||= FakeEngine.new
    end
  end

  def self.context(name, &block)
    instance_eval(&block)
  end

  def call_failure(env_params={})
    env = {
      'REQUEST_URI' => 'http://test.host/',
      'HTTP_HOST' => 'test.host',
      'REQUEST_METHOD' => 'GET',
      'warden.options' => { scope: :user },
      'rack.session' => {},
      'action_dispatch.request.formats' => Array(env_params.delete('formats') || Mime[:html]),
      'rack.input' => "",
      'warden' => OpenStruct.new(message: nil)
    }.merge!(env_params)

    # Passing nil for action_dispatch.request.formats prevents the default from being used in Rails 5, need to remove it
    if env.has_key?('action_dispatch.request.formats') && env['action_dispatch.request.formats'].nil?
      env.delete 'action_dispatch.request.formats' unless env['action_dispatch.request.formats']
    end

    @response = (env.delete(:app) || Devise::FailureApp).call(env).to_a
    @request  = ActionDispatch::Request.new(env)
  end

  context 'When redirecting' do
    test 'returns to the default redirect location' do
      call_failure
      assert_equal 302, @response.first
      assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second['Location']
    end

    test 'returns to the default redirect location considering subdomain' do
      call_failure('warden.options' => { scope: :subdomain_user })
      assert_equal 302, @response.first
      assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
      assert_equal 'http://sub.test.host/subdomain_users/sign_in', @response.second['Location']
    end

    test 'returns to the default redirect location for wildcard requests' do
      call_failure 'action_dispatch.request.formats' => nil, 'HTTP_ACCEPT' => '*/*'
      assert_equal 302, @response.first
      assert_equal 'http://test.host/users/sign_in', @response.second['Location']
    end

    test 'returns to the root path if no session path is available' do
      swap Devise, router_name: :fake_app do
        call_failure app: RootFailureApp
        assert_equal 302, @response.first
        assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
        assert_equal 'http://test.host/', @response.second['Location']
      end
    end

    test 'returns to the root path considering subdomain if no session path is available' do
      swap Devise, router_name: :fake_app do
        call_failure app: FailureWithSubdomain
        assert_equal 302, @response.first
        assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
        assert_equal 'http://sub.test.host/', @response.second['Location']
      end
    end

    test 'returns to the default redirect location considering the router for supplied scope' do
      call_failure app: FakeEngineApp, 'warden.options' => { scope: :user_on_engine }
      assert_equal 302, @response.first
      assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
      assert_equal 'http://test.host/user_on_engines/sign_in', @response.second['Location']
    end

    if Rails.application.config.respond_to?(:relative_url_root)
      test 'returns to the default redirect location considering the relative url root' do
        swap Rails.application.config, relative_url_root: "/sample" do
          call_failure
          assert_equal 302, @response.first
          assert_equal 'http://test.host/sample/users/sign_in', @response.second['Location']
        end
      end

      test 'returns to the default redirect location considering the relative url root and subdomain' do
        swap Rails.application.config, relative_url_root: "/sample" do
          call_failure('warden.options' => { scope: :subdomain_user })
          assert_equal 302, @response.first
          assert_equal 'http://sub.test.host/sample/subdomain_users/sign_in', @response.second['Location']
        end
      end
    end

    if Rails.application.config.action_controller.respond_to?(:relative_url_root)
      test "returns to the default redirect location considering action_controller's relative url root" do
        swap Rails.application.config.action_controller, relative_url_root: "/sample" do
          call_failure
          assert_equal 302, @response.first
          assert_equal 'http://test.host/sample/users/sign_in', @response.second['Location']
        end
      end

      test "returns to the default redirect location considering action_controller's relative url root and subdomain" do
        swap Rails.application.config.action_controller, relative_url_root: "/sample" do
          call_failure('warden.options' => { scope: :subdomain_user })
          assert_equal 302, @response.first
          assert_equal 'http://sub.test.host/sample/subdomain_users/sign_in', @response.second['Location']
        end
      end
    end

    test 'uses the proxy failure message as symbol' do
      call_failure('warden' => OpenStruct.new(message: :invalid))
      assert_equal 'Invalid Email or password.', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'supports authentication_keys as a Hash for the flash message' do
      swap Devise, authentication_keys: { email: true, login: true } do
        call_failure('warden' => OpenStruct.new(message: :invalid))
        assert_equal 'Invalid Email, Login or password.', @request.flash[:alert]
      end
    end

    test 'uses custom i18n options' do
      call_failure('warden' => OpenStruct.new(message: :does_not_exist), app: FailureWithI18nOptions)
      assert_equal 'User Steve does not exist', @request.flash[:alert]
    end

    test 'uses the proxy failure message as string' do
      call_failure('warden' => OpenStruct.new(message: 'Hello world'))
      assert_equal 'Hello world', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'set content type to default text/html' do
      call_failure
      assert_equal 'text/html; charset=utf-8', @response.second['Content-Type']
    end

    test 'set up a default message' do
      call_failure
      assert_match(/You are being/, @response.last.body)
      assert_match(/redirected/, @response.last.body)
      assert_match(/users\/sign_in/, @response.last.body)
    end

    test 'works for any navigational format' do
      swap Devise, navigational_formats: [:xml] do
        call_failure('formats' => Mime[:xml])
        assert_equal 302, @response.first
      end
    end

    test 'redirects the correct format if it is a non-html format request' do
      swap Devise, navigational_formats: [:js] do
        call_failure('formats' => Mime[:js])
        assert_equal 'http://test.host/users/sign_in.js', @response.second["Location"]
      end
    end
  end

  context 'For HTTP request' do
    test 'return 401 status' do
      call_failure('formats' => Mime[:xml])
      assert_equal 401, @response.first
    end

    test 'return appropriate body for xml' do
      call_failure('formats' => Mime[:xml])
      result = %(<?xml version="1.0" encoding="UTF-8"?>\n<errors>\n  <error>You need to sign in or sign up before continuing.</error>\n</errors>\n)
      assert_equal result, @response.last.body
    end

    test 'return appropriate body for json' do
      call_failure('formats' => Mime[:json])
      result = %({"error":"You need to sign in or sign up before continuing."})
      assert_equal result, @response.last.body
    end

    test 'return 401 status for unknown formats' do
      call_failure 'formats' => []
      assert_equal 401, @response.first
    end

    test 'return WWW-authenticate headers if model allows' do
      call_failure('formats' => Mime[:xml])
      assert_equal 'Basic realm="Application"', @response.second["WWW-Authenticate"]
    end

    test 'does not return WWW-authenticate headers if model does not allow' do
      swap Devise, http_authenticatable: false do
        call_failure('formats' => Mime[:xml])
        assert_nil @response.second["WWW-Authenticate"]
      end
    end

    test 'works for any non navigational format' do
      swap Devise, navigational_formats: [] do
        call_failure('formats' => Mime[:html])
        assert_equal 401, @response.first
      end
    end

    test 'uses the failure message as response body' do
      call_failure('formats' => Mime[:xml], 'warden' => OpenStruct.new(message: :invalid))
      assert_match '<error>Invalid Email or password.</error>', @response.third.body
    end

    context 'on ajax call' do
      context 'when http_authenticatable_on_xhr is false' do
        test 'dont return 401 with navigational formats' do
          swap Devise, http_authenticatable_on_xhr: false do
            call_failure('formats' => Mime[:html], 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
            assert_equal 302, @response.first
            assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
          end
        end

        test 'dont return 401 with non navigational formats' do
          swap Devise, http_authenticatable_on_xhr: false do
            call_failure('formats' => Mime[:json], 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
            assert_equal 302, @response.first
            assert_equal 'http://test.host/users/sign_in.json', @response.second["Location"]
          end
        end
      end

      context 'when http_authenticatable_on_xhr is true' do
        test 'return 401' do
          swap Devise, http_authenticatable_on_xhr: true do
            call_failure('formats' => Mime[:html], 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
            assert_equal 401, @response.first
          end
        end

        test 'skip WWW-Authenticate header' do
          swap Devise, http_authenticatable_on_xhr: true do
            call_failure('formats' => Mime[:html], 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
            assert_nil @response.second['WWW-Authenticate']
          end
        end
      end
    end
  end

  context 'With recall' do
    test 'calls the original controller if invalid email or password' do
      env = {
        "warden.options" => { recall: "devise/sessions#new", attempted_path: "/users/sign_in" },
        "devise.mapping" => Devise.mappings[:user],
        "warden" => stub_everything
      }
      call_failure(env)
      assert @response.third.body.include?('<h2>Log in</h2>')
      assert @response.third.body.include?('Invalid Email or password.')
    end

    test 'calls the original controller if not confirmed email' do
      env = {
        "warden.options" => { recall: "devise/sessions#new", attempted_path: "/users/sign_in", message: :unconfirmed },
        "devise.mapping" => Devise.mappings[:user],
        "warden" => stub_everything
      }
      call_failure(env)
      assert @response.third.body.include?('<h2>Log in</h2>')
      assert @response.third.body.include?('You have to confirm your email address before continuing.')
    end

    test 'calls the original controller if inactive account' do
      env = {
        "warden.options" => { recall: "devise/sessions#new", attempted_path: "/users/sign_in", message: :inactive },
        "devise.mapping" => Devise.mappings[:user],
        "warden" => stub_everything
      }
      call_failure(env)
      assert @response.third.body.include?('<h2>Log in</h2>')
      assert @response.third.body.include?('Your account is not activated yet.')
    end

    if Rails.application.config.respond_to?(:relative_url_root)
      test 'calls the original controller with the proper environment considering the relative url root' do
        swap Rails.application.config, relative_url_root: "/sample" do
          env = {
            "warden.options" => { recall: "devise/sessions#new", attempted_path: "/sample/users/sign_in"},
            "devise.mapping" => Devise.mappings[:user],
            "warden" => stub_everything
          }
          call_failure(env)
          assert @response.third.body.include?('<h2>Log in</h2>')
          assert @response.third.body.include?('Invalid Email or password.')
          assert_equal @request.env["SCRIPT_NAME"], '/sample'
          assert_equal @request.env["PATH_INFO"], '/users/sign_in'
        end
      end
    end
  end
end
