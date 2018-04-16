# frozen_string_literal: true

require 'test_helper'

ExpectedRoutingError = MiniTest::Assertion

class DefaultRoutingTest < ActionController::TestCase
  test 'map new user session' do
    assert_recognizes({controller: 'devise/sessions', action: 'new'}, {path: 'users/sign_in', method: :get})
    assert_named_route "/users/sign_in", :new_user_session_path
  end

  test 'map create user session' do
    assert_recognizes({controller: 'devise/sessions', action: 'create'}, {path: 'users/sign_in', method: :post})
    assert_named_route "/users/sign_in", :user_session_path
  end

  test 'map destroy user session' do
    assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: 'users/sign_out', method: :delete})
    assert_named_route "/users/sign_out", :destroy_user_session_path
  end

  test 'map new user confirmation' do
    assert_recognizes({controller: 'devise/confirmations', action: 'new'}, 'users/confirmation/new')
    assert_named_route "/users/confirmation/new", :new_user_confirmation_path
  end

  test 'map create user confirmation' do
    assert_recognizes({controller: 'devise/confirmations', action: 'create'}, {path: 'users/confirmation', method: :post})
    assert_named_route "/users/confirmation", :user_confirmation_path
  end

  test 'map show user confirmation' do
    assert_recognizes({controller: 'devise/confirmations', action: 'show'}, {path: 'users/confirmation', method: :get})
  end

  test 'map new user password' do
    assert_recognizes({controller: 'devise/passwords', action: 'new'}, 'users/password/new')
    assert_named_route "/users/password/new", :new_user_password_path
  end

  test 'map create user password' do
    assert_recognizes({controller: 'devise/passwords', action: 'create'}, {path: 'users/password', method: :post})
    assert_named_route "/users/password", :user_password_path
  end

  test 'map edit user password' do
    assert_recognizes({controller: 'devise/passwords', action: 'edit'}, 'users/password/edit')
    assert_named_route "/users/password/edit", :edit_user_password_path
  end

  test 'map update user password' do
    assert_recognizes({controller: 'devise/passwords', action: 'update'}, {path: 'users/password', method: :put})
  end

  test 'map new user unlock' do
    assert_recognizes({controller: 'devise/unlocks', action: 'new'}, 'users/unlock/new')
    assert_named_route "/users/unlock/new", :new_user_unlock_path
  end

  test 'map create user unlock' do
    assert_recognizes({controller: 'devise/unlocks', action: 'create'}, {path: 'users/unlock', method: :post})
    assert_named_route "/users/unlock", :user_unlock_path
  end

  test 'map show user unlock' do
    assert_recognizes({controller: 'devise/unlocks', action: 'show'}, {path: 'users/unlock', method: :get})
  end

  test 'map new user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'new'}, 'users/sign_up')
    assert_named_route "/users/sign_up", :new_user_registration_path
  end

  test 'map create user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'create'}, {path: 'users', method: :post})
    assert_named_route "/users", :user_registration_path
  end

  test 'map edit user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'edit'}, {path: 'users/edit', method: :get})
    assert_named_route "/users/edit", :edit_user_registration_path
  end

  test 'map update user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'update'}, {path: 'users', method: :put})
  end

  test 'map destroy user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'destroy'}, {path: 'users', method: :delete})
  end

  test 'map cancel user registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'cancel'}, {path: 'users/cancel', method: :get})
    assert_named_route "/users/cancel", :cancel_user_registration_path
  end

  test 'map omniauth callbacks' do
    assert_recognizes({controller: 'users/omniauth_callbacks', action: 'facebook'}, {path: 'users/auth/facebook/callback', method: :get})
    assert_recognizes({controller: 'users/omniauth_callbacks', action: 'facebook'}, {path: 'users/auth/facebook/callback', method: :post})
    assert_named_route "/users/auth/facebook/callback", :user_facebook_omniauth_callback_path

    # named open_id
    assert_recognizes({controller: 'users/omniauth_callbacks', action: 'google'}, {path: 'users/auth/google/callback', method: :get})
    assert_recognizes({controller: 'users/omniauth_callbacks', action: 'google'}, {path: 'users/auth/google/callback', method: :post})
    assert_named_route "/users/auth/google/callback", :user_google_omniauth_callback_path

    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'ysers/omniauth_callbacks', action: 'twitter'}, {path: 'users/auth/twitter/callback', method: :get})
    end
  end

  protected

  def assert_named_route(result, *args)
    assert_equal result, @routes.url_helpers.send(*args)
  end
end

class CustomizedRoutingTest < ActionController::TestCase
  test 'map admin with :path option' do
    assert_recognizes({controller: 'devise/registrations', action: 'new'}, {path: 'admin_area/sign_up', method: :get})
  end

  test 'map admin with :controllers option' do
    assert_recognizes({controller: 'admins/sessions', action: 'new'}, {path: 'admin_area/sign_in', method: :get})
  end

  test 'does not map admin password' do
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/passwords', action: 'new'}, 'admin_area/password/new')
    end
  end

  test 'subdomain admin' do
    assert_recognizes({"host"=>"sub.example.com", controller: 'devise/sessions', action: 'new'}, {host: "sub.example.com", path: '/sub_admin/sign_in', method: :get})
  end

  test 'does only map reader password' do
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/sessions', action: 'new'}, 'reader/sessions/new')
    end
    assert_recognizes({controller: 'devise/passwords', action: 'new'}, 'reader/password/new')
  end

  test 'map account with custom path name for session sign in' do
    assert_recognizes({controller: 'devise/sessions', action: 'new', locale: 'en'}, '/en/accounts/login')
  end

  test 'map account with custom path name for session sign out' do
    assert_recognizes({controller: 'devise/sessions', action: 'destroy', locale: 'en'}, {path: '/en/accounts/logout', method: :delete })
  end

  test 'map account with custom path name for password' do
    assert_recognizes({controller: 'devise/passwords', action: 'new', locale: 'en'}, '/en/accounts/secret/new')
  end

  test 'map account with custom path name for registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'new', locale: 'en'}, '/en/accounts/management/register')
  end

  test 'map account with custom path name for edit registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'edit', locale: 'en'}, '/en/accounts/management/edit/profile')
  end

  test 'map account with custom path name for cancel registration' do
    assert_recognizes({controller: 'devise/registrations', action: 'cancel', locale: 'en'}, '/en/accounts/management/giveup')
  end

  test 'map deletes with :sign_out_via option' do
    assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/deletes/sign_out', method: :delete})
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/deletes/sign_out', method: :get})
    end
  end

  test 'map posts with :sign_out_via option' do
    assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/posts/sign_out', method: :post})
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/posts/sign_out', method: :get})
    end
  end

  test 'map delete_or_posts with :sign_out_via option' do
    assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/delete_or_posts/sign_out', method: :post})
    assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/delete_or_posts/sign_out', method: :delete})
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/sessions', action: 'destroy'}, {path: '/sign_out_via/delete_or_posts/sign_out', method: :get})
    end
  end

  test 'map with constraints defined in hash' do
    assert_recognizes({controller: 'devise/registrations', action: 'new'}, {path: 'http://192.168.1.100/headquarters/sign_up', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/registrations', action: 'new'}, {path: 'http://10.0.0.100/headquarters/sign_up', method: :get})
    end
  end

  test 'map with constraints defined in block' do
    assert_recognizes({controller: 'devise/registrations', action: 'new'}, {path: 'http://192.168.1.100/homebase/sign_up', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes({controller: 'devise/registrations', action: 'new'}, {path: 'http://10.0.0.100//homebase/sign_up', method: :get})
    end
  end

  test 'map with format false for sessions' do
    expected_params = {controller: 'devise/sessions', action: 'new'}
    expected_params[:format] = false if Devise::Test.rails5?

    assert_recognizes(expected_params, {path: '/htmlonly_admin/sign_in', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes(expected_params, {path: '/htmlonly_admin/sign_in.xml', method: :get})
    end
  end

  test 'map with format false for passwords' do
    expected_params = {controller: 'devise/passwords', action: 'create'}
    expected_params[:format] = false if Devise::Test.rails5?

    assert_recognizes(expected_params, {path: '/htmlonly_admin/password', method: :post})
    assert_raise ExpectedRoutingError do
      assert_recognizes(expected_params, {path: '/htmlonly_admin/password.xml', method: :post})
    end
  end

  test 'map with format false for registrations' do
    expected_params = {controller: 'devise/registrations', action: 'new'}
    expected_params[:format] = false if Devise::Test.rails5?

    assert_recognizes(expected_params, {path: '/htmlonly_admin/sign_up', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes(expected_params, {path: '/htmlonly_admin/sign_up.xml', method: :get})
    end
  end

  test 'map with format false for confirmations' do
    expected_params = {controller: 'devise/confirmations', action: 'show'}
    expected_params[:format] = false if Devise::Test.rails5?

    assert_recognizes(expected_params, {path: '/htmlonly_users/confirmation', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes(expected_params, {path: '/htmlonly_users/confirmation.xml', method: :get})
    end
  end

  test 'map with format false for unlocks' do
    expected_params = {controller: 'devise/unlocks', action: 'show'}
    expected_params[:format] = false if Devise::Test.rails5?

    assert_recognizes(expected_params, {path: '/htmlonly_users/unlock', method: :get})
    assert_raise ExpectedRoutingError do
      assert_recognizes(expected_params, {path: '/htmlonly_users/unlock.xml', method: :get})
    end
  end

  test 'map with format false is not permanent' do
    assert_equal "/set.xml", @routes.url_helpers.set_path(:xml)
  end

  test 'checks if mapping has proper configuration for omniauth callback' do
    e = assert_raise ArgumentError do
      routes = ActionDispatch::Routing::RouteSet.new
      routes.draw do
        devise_for :not_omniauthable, class_name: 'Admin', controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
      end
    end
    assert_match "Mapping omniauth_callbacks on a resource that is not omniauthable", e.message
  end
end

class ScopedRoutingTest < ActionController::TestCase
  test 'map publisher account' do
    assert_recognizes({controller: 'publisher/registrations', action: 'new'}, {path: '/publisher/accounts/sign_up', method: :get})
    assert_equal '/publisher/accounts/sign_up', @routes.url_helpers.new_publisher_account_registration_path
  end

  test 'map publisher account merges path names' do
    assert_recognizes({controller: 'publisher/sessions', action: 'new'}, {path: '/publisher/accounts/get_in', method: :get})
    assert_equal '/publisher/accounts/get_in', @routes.url_helpers.new_publisher_account_session_path
  end
end
