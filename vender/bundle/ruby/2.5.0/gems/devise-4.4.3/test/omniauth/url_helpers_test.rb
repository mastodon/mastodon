# frozen_string_literal: true

require 'test_helper'

class OmniAuthRoutesTest < ActionController::TestCase
  tests ApplicationController

  def assert_path(action, provider, with_param=true)
    # Resource param
    assert_equal @controller.send(action, :user, provider),
                 @controller.send("user_#{provider}_#{action}")

    # With an object
    assert_equal @controller.send(action, User.new, provider),
                 @controller.send("user_#{provider}_#{action}")

    if with_param
      # Default url params
      assert_equal @controller.send(action, :user, provider, param: 123),
                   @controller.send("user_#{provider}_#{action}", param: 123)
    end
  end

  test 'should alias omniauth_callback to mapped user auth_callback' do
    assert_path :omniauth_callback_path, :facebook
  end

  test 'should alias omniauth_authorize to mapped user auth_authorize' do
    assert_path :omniauth_authorize_path, :facebook, false
  end

  test 'should generate authorization path' do
    assert_match "/users/auth/facebook", @controller.omniauth_authorize_path(:user, :facebook)

    assert_raise NoMethodError do
      @controller.omniauth_authorize_path(:user, :github)
    end
  end

  test 'should generate authorization path for named open_id omniauth' do
    assert_match "/users/auth/google", @controller.omniauth_authorize_path(:user, :google)
  end

  test 'should generate authorization path with params' do
    assert_match "/users/auth/openid?openid_url=http%3A%2F%2Fyahoo.com",
                  @controller.omniauth_authorize_path(:user, :openid, openid_url: "http://yahoo.com")
  end

  test 'should not add a "?" if no param was sent' do
    assert_equal "/users/auth/openid",
                  @controller.omniauth_authorize_path(:user, :openid)
  end
end
