# frozen_string_literal: true

require 'test_helper'

class LockTest < Devise::IntegrationTest

  def visit_user_unlock_with_token(unlock_token)
    visit user_unlock_path(unlock_token: unlock_token)
  end

  def send_unlock_request
    user = create_user(locked: true)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive unlock instructions?"

    Devise.stubs(:friendly_token).returns("abcdef")
    fill_in 'email', with: user.email
    click_button 'Resend unlock instructions'
  end

  test 'user should be able to request a new unlock token' do
    send_unlock_request

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions for how to unlock your account in a few minutes'

    mail = ActionMailer::Base.deliveries.last
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal ['please-change-me@config-initializers-devise.com'], mail.from
    assert_match user_unlock_path(unlock_token: 'abcdef'), mail.body.encoded
  end

  test 'user should receive the instructions from a custom mailer' do
    User.any_instance.stubs(:devise_mailer).returns(Users::Mailer)

    send_unlock_request

    assert_equal ['custom@example.com'], ActionMailer::Base.deliveries.first.from
  end

  test 'unlocked user should not be able to request a unlock token' do
    user = create_user(locked: false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive unlock instructions?"

    fill_in 'email', with: user.email
    click_button 'Resend unlock instructions'

    assert_template 'unlocks/new'
    assert_contain 'not locked'
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'unlocked pages should not be available if email strategy is disabled' do
    visit "/admin_area/sign_in"

    assert_raise Webrat::NotFoundError do
      click_link "Didn't receive unlock instructions?"
    end

    assert_raise NameError do
      visit new_admin_unlock_path
    end

    assert_raise ActionController::RoutingError do
      visit "/admin_area/unlock/new"
    end
  end

  test 'user with invalid unlock token should not be able to unlock an account' do
    visit_user_unlock_with_token('invalid_token')

    assert_response :success
    assert_current_url '/users/unlock?unlock_token=invalid_token'
    assert_have_selector '#error_explanation'
    assert_contain %r{Unlock token(.*)invalid}
  end

  test "locked user should be able to unlock account" do
    user = create_user
    raw  = user.lock_access!
    visit_user_unlock_with_token(raw)

    assert_current_url "/users/sign_in"
    assert_contain 'Your account has been unlocked successfully. Please sign in to continue.'
    refute user.reload.access_locked?
  end

  test "user should not send a new e-mail if already locked" do
    user = create_user(locked: true)
    user.failed_attempts = User.maximum_attempts + 1
    user.save!

    ActionMailer::Base.deliveries.clear

    sign_in_as_user(password: "invalid")
    assert_contain 'Your account is locked.'
    assert ActionMailer::Base.deliveries.empty?
  end

  test 'error message is configurable by resource name' do
    store_translations :en, devise: {
        failure: {user: {locked: "You are locked!"}}
    } do

      user = create_user(locked: true)
      user.failed_attempts = User.maximum_attempts + 1
      user.save!

      sign_in_as_user(password: "invalid")
      assert_contain "You are locked!"
    end
  end

  test "user should not be able to sign in when locked" do
    store_translations :en, devise: {
        failure: {user: {locked: "You are locked!"}}
    } do

      user = create_user(locked: true)
      user.failed_attempts = User.maximum_attempts + 1
      user.save!

      sign_in_as_user(password: "123456")
      assert_contain "You are locked!"
    end
  end

  test 'user should be able to request a new unlock token via XML request' do
    user = create_user(locked: true)
    ActionMailer::Base.deliveries.clear

    post user_unlock_path(format: 'xml'), params: { user: {email: user.email} }
    assert_response :success
    assert_equal response.body, {}.to_xml

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'unlocked user should not be able to request a unlock token via XML request' do
    user = create_user(locked: false)
    ActionMailer::Base.deliveries.clear

    post user_unlock_path(format: 'xml'), params: { user: {email: user.email} }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'user with valid unlock token should be able to unlock account via XML request' do
    user = create_user()
    raw  = user.lock_access!
    assert user.access_locked?
    get user_unlock_path(format: 'xml', unlock_token: raw)
    assert_response :success
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>)
  end


  test 'user with invalid unlock token should not be able to unlock the account via XML request' do
    get user_unlock_path(format: 'xml', unlock_token: 'invalid_token')
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test "when using json to ask a unlock request, should not return the user" do
    user = create_user(locked: true)
    post user_unlock_path(format: "json", user: {email: user.email})
    assert_response :success
    assert_equal response.body, {}.to_json
  end

  test "in paranoid mode, when trying to unlock a user that exists it should not say that it exists if it is locked" do
    swap Devise, paranoid: true do
      user = create_user(locked: true)

      visit new_user_session_path
      click_link "Didn't receive unlock instructions?"

      fill_in 'email', with: user.email
      click_button 'Resend unlock instructions'

      assert_current_url "/users/sign_in"
      assert_contain "If your account exists, you will receive an email with instructions for how to unlock it in a few minutes."
    end
  end

  test "in paranoid mode, when trying to unlock a user that exists it should not say that it exists if it is not locked" do
    swap Devise, paranoid: true do
      user = create_user(locked: false)

      visit new_user_session_path
      click_link "Didn't receive unlock instructions?"

      fill_in 'email', with: user.email
      click_button 'Resend unlock instructions'

      assert_current_url "/users/sign_in"
      assert_contain "If your account exists, you will receive an email with instructions for how to unlock it in a few minutes."
    end
  end

  test "in paranoid mode, when trying to unlock a user that does not exists it should not say that it does not exists" do
    swap Devise, paranoid: true do
      visit new_user_session_path
      click_link "Didn't receive unlock instructions?"

      fill_in 'email', with: "arandomemail@hotmail.com"
      click_button 'Resend unlock instructions'

      assert_not_contain "1 error prohibited this user from being saved:"
      assert_not_contain "Email not found"
      assert_current_url "/users/sign_in"

      assert_contain "If your account exists, you will receive an email with instructions for how to unlock it in a few minutes."

    end
  end

  test "in paranoid mode, when locking a user that exists it should not say that the user was locked" do
    swap Devise, paranoid: true, maximum_attempts: 1 do
      user = create_user(locked: false)

      visit new_user_session_path
      fill_in 'email', with: user.email
      fill_in 'password', with: "abadpassword"
      click_button 'Log in'

      fill_in 'email', with: user.email
      fill_in 'password', with: "abadpassword"
      click_button 'Log in'

      assert_current_url "/users/sign_in"
      assert_not_contain "locked"
    end
  end

end
