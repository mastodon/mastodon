# frozen_string_literal: true

require 'test_helper'

class PasswordTest < Devise::IntegrationTest

  def visit_new_password_path
    visit new_user_session_path
    click_link 'Forgot your password?'
  end

  def request_forgot_password(&block)
    visit_new_password_path
    assert_response :success
    refute warden.authenticated?(:user)

    fill_in 'email', with: 'user@test.com'
    yield if block_given?

    Devise.stubs(:friendly_token).returns("abcdef")
    click_button 'Send me reset password instructions'
  end

  def reset_password(options={}, &block)
    unless options[:visit] == false
      visit edit_user_password_path(reset_password_token: options[:reset_password_token] || "abcdef")
      assert_response :success
    end

    fill_in 'New password', with: '987654321'
    fill_in 'Confirm new password', with: '987654321'
    yield if block_given?
    click_button 'Change my password'
  end

  test 'reset password with email of different case should succeed when email is in the list of case insensitive keys' do
    create_user(email: 'Foo@Bar.com')

    request_forgot_password do
      fill_in 'email', with: 'foo@bar.com'
    end

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions on how to reset your password in a few minutes.'
  end

  test 'reset password with email should send an email from a custom mailer' do
    create_user(email: 'Foo@Bar.com')

    User.any_instance.stubs(:devise_mailer).returns(Users::Mailer)
    request_forgot_password do
      fill_in 'email', with: 'foo@bar.com'
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal ['custom@example.com'], mail.from
    assert_match edit_user_password_path(reset_password_token: 'abcdef'), mail.body.encoded
  end

  test 'reset password with email of different case should fail when email is NOT the list of case insensitive keys' do
    swap Devise, case_insensitive_keys: [] do
      create_user(email: 'Foo@Bar.com')

      request_forgot_password do
        fill_in 'email', with: 'foo@bar.com'
      end

      assert_response :success
      assert_current_url '/users/password'
      assert_have_selector "input[type=email][value='foo@bar.com']"
      assert_contain 'not found'
    end
  end

  test 'reset password with email with extra whitespace should succeed when email is in the list of strip whitespace keys' do
    create_user(email: 'foo@bar.com')

    request_forgot_password do
      fill_in 'email', with: ' foo@bar.com '
    end

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions on how to reset your password in a few minutes.'
  end

  test 'reset password with email with extra whitespace should fail when email is NOT the list of strip whitespace keys' do
    swap Devise, strip_whitespace_keys: [] do
      create_user(email: 'foo@bar.com')

      request_forgot_password do
        fill_in 'email', with: ' foo@bar.com '
      end

      assert_response :success
      assert_current_url '/users/password'
      assert_have_selector "input[type=email][value=' foo@bar.com ']"
      assert_contain 'not found'
    end
  end

  test 'authenticated user should not be able to visit forgot password page' do
    sign_in_as_user
    assert warden.authenticated?(:user)

    get new_user_password_path

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'not authenticated user should be able to request a forgot password' do
    create_user
    request_forgot_password

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions on how to reset your password in a few minutes.'
  end

  test 'not authenticated user with invalid email should receive an error message' do
    request_forgot_password do
      fill_in 'email', with: 'invalid.test@test.com'
    end

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector "input[type=email][value='invalid.test@test.com']"
    assert_contain 'not found'
  end

  test 'authenticated user should not be able to visit edit password page' do
    sign_in_as_user
    get edit_user_password_path
    assert_response :redirect
    assert_redirected_to root_path
    assert warden.authenticated?(:user)
  end

  test 'not authenticated user without a reset password token should not be able to visit the page' do
    get edit_user_password_path
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
  end

  test 'not authenticated user with invalid reset password token should not be able to change their password' do
    user = create_user
    reset_password reset_password_token: 'invalid_reset_password'

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector '#error_explanation'
    assert_contain %r{Reset password token(.*)invalid}
    refute user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid reset password token but invalid password should not be able to change their password' do
    user = create_user
    request_forgot_password
    reset_password do
      fill_in 'Confirm new password', with: 'other_password'
    end

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector '#error_explanation'
    assert_contain "Password confirmation doesn't match Password"
    refute user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid data should be able to change their password' do
    user = create_user
    request_forgot_password
    reset_password

    assert_current_url '/'
    assert_contain 'Your password has been changed successfully. You are now signed in.'
    assert user.reload.valid_password?('987654321')
  end

  test 'after entering invalid data user should still be able to change their password' do
    user = create_user
    request_forgot_password

    reset_password {  fill_in 'Confirm new password', with: 'other_password' }
    assert_response :success
    assert_have_selector '#error_explanation'
    refute user.reload.valid_password?('987654321')

    reset_password visit: false
    assert_contain 'Your password has been changed successfully.'
    assert user.reload.valid_password?('987654321')
  end

  test 'sign in user automatically after changing its password' do
    create_user
    request_forgot_password
    reset_password

    assert warden.authenticated?(:user)
  end

  test 'does not sign in user automatically after changing its password if config.sign_in_after_reset_password is false' do
    swap Devise, sign_in_after_reset_password: false do
      create_user
      request_forgot_password
      reset_password

      assert_contain 'Your password has been changed successfully.'
      assert_not_contain 'You are now signed in.'
      assert_equal new_user_session_path, @request.path
      assert !warden.authenticated?(:user)
    end
  end

  test 'does not sign in user automatically after changing its password if it\'s locked and unlock strategy is :none or :time' do
    [:none, :time].each do |strategy|
      swap Devise, unlock_strategy: strategy do
        create_user(locked: true)
        request_forgot_password
        reset_password

        assert_contain 'Your password has been changed successfully.'
        assert_not_contain 'You are now signed in.'
        assert_equal new_user_session_path, @request.path
        assert !warden.authenticated?(:user)
      end
    end
  end

  test 'unlocks and signs in locked user automatically after changing it\'s password if unlock strategy is :email' do
    swap Devise, unlock_strategy: :email do
      user = create_user(locked: true)
      request_forgot_password
      reset_password

      assert_contain 'Your password has been changed successfully.'
      assert !user.reload.access_locked?
      assert warden.authenticated?(:user)
    end
  end

  test 'unlocks and signs in locked user automatically after changing it\'s password if unlock strategy is :both' do
    swap Devise, unlock_strategy: :both do
      user = create_user(locked: true)
      request_forgot_password
      reset_password

      assert_contain 'Your password has been changed successfully.'
      assert !user.reload.access_locked?
      assert warden.authenticated?(:user)
    end
  end

  test 'reset password request with valid E-Mail in XML format should return valid response' do
    create_user
    post user_password_path(format: 'xml'), params: { user: {email: "user@test.com"} }
    assert_response :success
    assert_equal response.body, { }.to_xml
  end

  test 'reset password request with invalid E-Mail in XML format should return valid response' do
    create_user
    post user_password_path(format: 'xml'), params: { user: {email: "invalid.test@test.com"} }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'reset password request with invalid E-Mail in XML format should return empty and valid response' do
    swap Devise, paranoid: true do
      create_user
      post user_password_path(format: 'xml'), params: { user: {email: "invalid@test.com"} }
      assert_response :success
      assert_equal response.body, { }.to_xml
    end
  end

  test 'change password with valid parameters in XML format should return valid response' do
    create_user
    request_forgot_password
    put user_password_path(format: 'xml'), params: { user: {
      reset_password_token: 'abcdef', password: '987654321', password_confirmation: '987654321'
      }
    }
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'change password with invalid token in XML format should return invalid response' do
    create_user
    request_forgot_password
    put user_password_path(format: 'xml'), params: { user: {reset_password_token: 'invalid.token', password: '987654321', password_confirmation: '987654321'} }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'change password with invalid new password in XML format should return invalid response' do
    user = create_user
    request_forgot_password
    put user_password_path(format: 'xml'), params: { user: {reset_password_token: user.reload.reset_password_token, password: '', password_confirmation: '987654321'} }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test "when using json requests to ask a confirmable request, should not return the object" do
    user = create_user(confirm: false)

    post user_password_path(format: :json), params: { user: { email: user.email } }

    assert_response :success
    assert_equal response.body, "{}"
  end

  test "when in paranoid mode and with an invalid e-mail, asking to reset a password should display a message that does not indicates that the e-mail does not exists in the database" do
    swap Devise, paranoid: true do
      visit_new_password_path
      fill_in "email", with: "arandomemail@test.com"
      click_button 'Send me reset password instructions'

      assert_not_contain "1 error prohibited this user from being saved:"
      assert_not_contain "Email not found"
      assert_contain "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
      assert_current_url "/users/sign_in"
    end
  end

  test "when in paranoid mode and with a valid e-mail, asking to reset password should display a message that does not indicates that the email exists in the database and redirect to the failure route" do
    swap Devise, paranoid: true do
      user = create_user
      visit_new_password_path
      fill_in 'email', with: user.email
      click_button 'Send me reset password instructions'

      assert_contain "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
      assert_current_url "/users/sign_in"
    end
  end

  test "after recovering a password, should set failed attempts to 0" do
    user = create_user
    user.update_attribute(:failed_attempts, 10)

    assert_equal 10, user.failed_attempts
    request_forgot_password
    reset_password

    assert warden.authenticated?(:user)
    user.reload
    assert_equal 0, user.failed_attempts
  end
end
