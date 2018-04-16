# frozen_string_literal: true

require 'test_helper'

class RememberMeTest < Devise::IntegrationTest
  def create_user_and_remember(add_to_token='')
    user = create_user
    user.remember_me!
    raw_cookie = User.serialize_into_cookie(user).tap { |a| a[1] << add_to_token }
    cookies['remember_user_token'] = generate_signed_cookie(raw_cookie)
    user
  end

  def generate_signed_cookie(raw_cookie)
    request = if Devise::Test.rails51? || Devise::Test.rails52?
      ActionController::TestRequest.create(Class.new) # needs a "controller class"
    elsif Devise::Test.rails5?
      ActionController::TestRequest.create
    else
      ActionController::TestRequest.new
    end
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  def signed_cookie(key)
    controller.send(:cookies).signed[key]
  end

  def cookie_expires(key)
    cookie  = response.headers["Set-Cookie"].split("\n").grep(/^#{key}/).first
    expires = cookie.split(";").map(&:strip).grep(/^expires=/).first
    Time.parse(expires).utc
  end

  test 'do not remember the user if they have not checked remember me option' do
    sign_in_as_user
    assert_nil request.cookies["remember_user_cookie"]
  end

  test 'handle unverified requests gets rid of caches' do
    swap ApplicationController, allow_forgery_protection: true do
      post exhibit_user_url(1)
      refute warden.authenticated?(:user)

      create_user_and_remember
      post exhibit_user_url(1)
      assert_equal "User is not authenticated", response.body
      refute warden.authenticated?(:user)
    end
  end

  test 'handle unverified requests does not create cookies on sign in' do
    swap ApplicationController, allow_forgery_protection: true do
      get new_user_session_path
      assert request.session[:_csrf_token]

      post user_session_path, params: {
          authenticity_token: "oops",
          user: { email: "jose.valim@gmail.com", password: "123456", remember_me: "1" }
        }
      refute warden.authenticated?(:user)
      refute request.cookies['remember_user_token']
    end
  end

  test 'generate remember token after sign in' do
    sign_in_as_user remember_me: true
    assert request.cookies['remember_user_token']
  end

  test 'generate remember token after sign in setting cookie options' do
    # We test this by asserting the cookie is not sent after the redirect
    # since we changed the domain. This is the only difference with the
    # previous test.
    swap Devise, rememberable_options: { domain: "omg.somewhere.com" } do
      sign_in_as_user remember_me: true
      assert_nil request.cookies["remember_user_token"]
    end
  end

  test 'generate remember token with a custom key' do
    swap Devise, rememberable_options: { key: "v1lat_token" } do
      sign_in_as_user remember_me: true
      assert request.cookies["v1lat_token"]
    end
  end

  test 'generate remember token after sign in setting session options' do
    begin
      Rails.configuration.session_options[:domain] = "omg.somewhere.com"
      sign_in_as_user remember_me: true
      assert_nil request.cookies["remember_user_token"]
    ensure
      Rails.configuration.session_options.delete(:domain)
    end
  end

  test 'remember the user before sign in' do
    user = create_user_and_remember
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert warden.user(:user) == user
  end

  test 'remember the user before sign up and redirect them to their home' do
    create_user_and_remember
    get new_user_registration_path
    assert warden.authenticated?(:user)
    assert_redirected_to root_path
  end

  test 'does not extend remember period through sign in' do
    swap Devise, extend_remember_period: true, remember_for: 1.year do
      user = create_user
      user.remember_me!

      user.remember_created_at = old = 10.days.ago
      user.save

      sign_in_as_user remember_me: true
      user.reload

      assert warden.user(:user) == user
      assert_equal old.to_i, user.remember_created_at.to_i
    end
  end

  test 'extends remember period when extend remember period config is true' do
    swap Devise, extend_remember_period: true, remember_for: 1.year do
      create_user_and_remember
      old_remember_token = nil

      travel_to 1.day.ago do
        get root_path
        old_remember_token = request.cookies['remember_user_token']
      end

      get root_path
      current_remember_token = request.cookies['remember_user_token']

      refute_equal old_remember_token, current_remember_token
    end
  end

  test 'does not extend remember period when extend period config is false' do
    swap Devise, extend_remember_period: false, remember_for: 1.year do
      create_user_and_remember
      old_remember_token = nil

      travel_to 1.day.ago do
        get root_path
        old_remember_token = request.cookies['remember_user_token']
      end

      get root_path
      current_remember_token = request.cookies['remember_user_token']

      assert_equal old_remember_token, current_remember_token
    end
  end

  test 'do not remember other scopes' do
    create_user_and_remember
    get root_path
    assert_response :success
    assert warden.authenticated?(:user)
    refute warden.authenticated?(:admin)
  end

  test 'do not remember with invalid token' do
    create_user_and_remember('add')
    get users_path
    refute warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test 'do not remember with expired token' do
    create_user_and_remember
    swap Devise, remember_for: 0.days do
      get users_path
      refute warden.authenticated?(:user)
      assert_redirected_to new_user_session_path
    end
  end

  test 'do not remember the user anymore after forget' do
    create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)

    delete destroy_user_session_path
    refute warden.authenticated?(:user)
    assert_nil warden.cookies['remember_user_token']

    get users_path
    refute warden.authenticated?(:user)
  end

  test 'changing user password expires remember me token' do
    user = create_user_and_remember
    user.password = "another_password"
    user.password_confirmation = "another_password"
    user.save!

    get users_path
    refute warden.authenticated?(:user)
  end

  test 'valid sign in calls after_remembered callback' do
    user = create_user_and_remember

    User.expects(:serialize_from_cookie).returns user
    user.expects :after_remembered

    get new_user_registration_path
  end
end
