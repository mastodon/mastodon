# frozen_string_literal: true

require 'test_helper'

class SessionTimeoutTest < Devise::IntegrationTest

  def last_request_at
    @controller.user_session['last_request_at']
  end

  test 'set last request at in user session after each request' do
    sign_in_as_user
    assert_not_nil last_request_at

    @controller.user_session.delete('last_request_at')
    get users_path
    assert_not_nil last_request_at
  end

  test 'set last request at in user session after each request is skipped if tracking is disabled' do
    sign_in_as_user
    old_last_request = last_request_at
    assert_not_nil last_request_at

    get users_path, headers: { 'devise.skip_trackable' => true }
    assert_equal old_last_request, last_request_at
  end

  test 'does not set last request at in user session after each request if timeoutable is disabled' do
    sign_in_as_user
    old_last_request = last_request_at
    assert_not_nil last_request_at

    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)

    get users_path, headers: { 'devise.skip_timeoutable' => true }
    assert_equal old_last_request, last_request_at
  end

  test 'does not time out user session before default limit time' do
    sign_in_as_user
    assert_response :success
    assert warden.authenticated?(:user)

    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'time out user session after default limit time when sign_out_all_scopes is false' do
    swap Devise, sign_out_all_scopes: false do
      sign_in_as_admin

      user = sign_in_as_user
      get expire_user_path(user)
      assert_not_nil last_request_at

      get users_path
      assert_redirected_to users_path
      refute warden.authenticated?(:user)
      assert warden.authenticated?(:admin)
    end
  end

  test 'time out all sessions after default limit time when sign_out_all_scopes is true' do
    swap Devise, sign_out_all_scopes: true do
      sign_in_as_admin

      user = sign_in_as_user
      get expire_user_path(user)
      assert_not_nil last_request_at

      get root_path
      refute warden.authenticated?(:user)
      refute warden.authenticated?(:admin)
    end
  end

  test 'time out user session after deault limit time and redirect to latest get request' do
    user = sign_in_as_user
    visit edit_form_user_path(user)

    click_button 'Update'
    sign_in_as_user

    assert_equal edit_form_user_url(user), current_url
  end

  test 'time out is not triggered on sign out' do
    user = sign_in_as_user
    get expire_user_path(user)

    delete destroy_user_session_path

    assert_response :redirect
    assert_redirected_to root_path
    follow_redirect!
    assert_contain 'Signed out successfully'
  end

  test 'expired session is not extended by sign in page' do
    user = sign_in_as_user
    get expire_user_path(user)
    assert warden.authenticated?(:user)

    get "/users/sign_in"
    assert_redirected_to "/users/sign_in"
    follow_redirect!

    assert_response :success
    assert_contain 'Sign in'
    refute warden.authenticated?(:user)
  end

  test 'time out is not triggered on sign in' do
    user = sign_in_as_user
    get expire_user_path(user)

    post "/users/sign_in", params: { email: user.email, password: "123456" }

    assert_response :redirect
    follow_redirect!
    assert_contain 'You are signed in'
  end

  test 'user configured timeout limit' do
    swap Devise, timeout_in: 8.minutes do
      user = sign_in_as_user

      get users_path
      assert_not_nil last_request_at
      assert_response :success
      assert warden.authenticated?(:user)

      get expire_user_path(user)
      get users_path
      assert_redirected_to users_path
      refute warden.authenticated?(:user)
    end
  end

  test 'error message with i18n' do
    store_translations :en, devise: {
      failure: { user: { timeout: 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get root_path
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end

  test 'error message with i18n with double redirect' do
    store_translations :en, devise: {
      failure: { user: { timeout: 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get users_path
      follow_redirect!
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end

  test 'time out not triggered if remembered' do
    user = sign_in_as_user remember_me: true
    get expire_user_path(user)
    assert_not_nil last_request_at

    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'does not crash when the last_request_at is a String' do
    user = sign_in_as_user

    get edit_form_user_path(user, last_request_at: Time.now.utc.to_s)
    get users_path
  end
end
