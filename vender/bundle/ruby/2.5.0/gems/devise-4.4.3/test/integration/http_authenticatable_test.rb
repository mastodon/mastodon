# frozen_string_literal: true

require 'test_helper'

class HttpAuthenticationTest < Devise::IntegrationTest
  test 'sign in with HTTP should not run model validations' do
    sign_in_as_new_user_with_http

    refute User.validations_performed
  end

  test 'handles unverified requests gets rid of caches but continues signed in' do
    swap ApplicationController, allow_forgery_protection: true do
      create_user
      post exhibit_user_url(1), headers: { "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("user@test.com:12345678")}" }
      assert warden.authenticated?(:user)
      assert_equal "User is authenticated", response.body
    end
  end

  test 'sign in should authenticate with http' do
    swap Devise, skip_session_storage: [] do
      sign_in_as_new_user_with_http
      assert_response 200
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)

      get users_path(format: :xml)
      assert_response 200
    end
  end

  test 'sign in should authenticate with http but not emit a cookie if skipping session storage' do
    swap Devise, skip_session_storage: [:http_auth] do
      sign_in_as_new_user_with_http
      assert_response 200
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)

      get users_path(format: :xml)
      assert_response 401
    end
  end

  test 'returns a custom response with www-authenticate header on failures' do
    sign_in_as_new_user_with_http("unknown")
    assert_equal 401, status
    assert_equal 'Basic realm="Application"', headers["WWW-Authenticate"]
  end

  test 'uses the request format as response content type' do
    sign_in_as_new_user_with_http("unknown")
    assert_equal 401, status
    assert_equal "application/xml; charset=utf-8", headers["Content-Type"]
    assert_match "<error>Invalid Email or password.</error>", response.body
  end

  test 'returns a custom response with www-authenticate and chosen realm' do
    swap Devise, http_authentication_realm: "MyApp" do
      sign_in_as_new_user_with_http("unknown")
      assert_equal 401, status
      assert_equal 'Basic realm="MyApp"', headers["WWW-Authenticate"]
    end
  end

  test 'sign in should authenticate with http even with specific authentication keys' do
    swap Devise, authentication_keys: [:username] do
      sign_in_as_new_user_with_http("usertest")
      assert_response :success
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)
    end
  end

  test 'it uses appropriate authentication_keys when configured with hash' do
    swap Devise, authentication_keys: { username: false, email: false } do
      sign_in_as_new_user_with_http("usertest")
      assert_response :success
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)
    end
  end

  test 'it uses the appropriate key when configured explicitly' do
    swap Devise, authentication_keys: { email: false, username: false }, http_authentication_key: :username do
      sign_in_as_new_user_with_http("usertest")
      assert_response :success
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)
    end
  end

  test 'test request with oauth2 header doesnt get mistaken for basic authentication' do
    swap Devise, http_authenticatable: true do
      add_oauth2_header
      assert_equal 401, status
      assert_equal 'Basic realm="Application"', headers["WWW-Authenticate"]
    end
  end

  private
    def sign_in_as_new_user_with_http(username="user@test.com", password="12345678")
      user = create_user
      get users_path(format: :xml), headers: { "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("#{username}:#{password}")}" }
      user
    end

    # Sign in with oauth2 token. This is just to test that it isn't misinterpreted as basic authentication
    def add_oauth2_header
      user = create_user
      get users_path(format: :xml), headers: { "HTTP_AUTHORIZATION" => "OAuth #{Base64.encode64("#{user.email}:12345678")}" }
    end

end
