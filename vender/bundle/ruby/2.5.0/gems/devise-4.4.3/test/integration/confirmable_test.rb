# frozen_string_literal: true

require 'test_helper'

class ConfirmationTest < Devise::IntegrationTest

  def visit_user_confirmation_with_token(confirmation_token)
    visit user_confirmation_path(confirmation_token: confirmation_token)
  end

  def resend_confirmation
    user = create_user(confirm: false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive confirmation instructions?"

    fill_in 'email', with: user.email
    click_button 'Resend confirmation instructions'
  end

  test 'user should be able to request a new confirmation' do
    resend_confirmation

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions for how to confirm your email address in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal ['please-change-me@config-initializers-devise.com'], ActionMailer::Base.deliveries.first.from
  end

  test 'user should receive a confirmation from a custom mailer' do
    User.any_instance.stubs(:devise_mailer).returns(Users::Mailer)
    resend_confirmation
    assert_equal ['custom@example.com'], ActionMailer::Base.deliveries.first.from
  end

  test 'user with invalid confirmation token should not be able to confirm an account' do
    visit_user_confirmation_with_token('invalid_confirmation')
    assert_have_selector '#error_explanation'
    assert_contain %r{Confirmation token(.*)invalid}
  end

  test 'user with valid confirmation token should not be able to confirm an account after the token has expired' do
    swap Devise, confirm_within: 3.days do
      user = create_user(confirm: false, confirmation_sent_at: 4.days.ago)
      refute user.confirmed?
      visit_user_confirmation_with_token(user.raw_confirmation_token)

      assert_have_selector '#error_explanation'
      assert_contain %r{needs to be confirmed within 3 days}
      refute user.reload.confirmed?
      assert_current_url "/users/confirmation?confirmation_token=#{user.raw_confirmation_token}"
    end
  end

  test 'user with valid confirmation token where the token has expired and with application router_name set to a different engine it should raise an error' do
    user = create_user(confirm: false, confirmation_sent_at: 4.days.ago)

    swap Devise, confirm_within: 3.days, router_name: :fake_engine do
      assert_raise ActionView::Template::Error do
        visit_user_confirmation_with_token(user.raw_confirmation_token)
      end
    end
  end

  test 'user with valid confirmation token where the token has expired and with application router_name set to a different engine and route overrides back to main it shows the path' do
    user = create_user(confirm: false, confirmation_sent_at: 4.days.ago)

    swap Devise, confirm_within: 3.days, router_name: :fake_engine do
      visit user_on_main_app_confirmation_path(confirmation_token: user.raw_confirmation_token)

      assert_current_url "/user_on_main_apps/confirmation?confirmation_token=#{user.raw_confirmation_token}"
    end
  end

  test 'user with valid confirmation token where the token has expired with router overrides different engine it shows the path' do
    user = create_user(confirm: false, confirmation_sent_at: 4.days.ago)

    swap Devise, confirm_within: 3.days do
      visit user_on_engine_confirmation_path(confirmation_token: user.raw_confirmation_token)

      assert_current_url "/user_on_engines/confirmation?confirmation_token=#{user.raw_confirmation_token}"
    end
  end

  test 'user with valid confirmation token should be able to confirm an account before the token has expired' do
    swap Devise, confirm_within: 3.days do
      user = create_user(confirm: false, confirmation_sent_at: 2.days.ago)
      refute user.confirmed?
      visit_user_confirmation_with_token(user.raw_confirmation_token)

      assert_contain 'Your email address has been successfully confirmed.'
      assert_current_url '/users/sign_in'
      assert user.reload.confirmed?
    end
  end

  test 'user should be redirected to a custom path after confirmation' do
    Devise::ConfirmationsController.any_instance.stubs(:after_confirmation_path_for).returns("/?custom=1")

    user = create_user(confirm: false)
    visit_user_confirmation_with_token(user.raw_confirmation_token)

    assert_current_url "/?custom=1"
  end

  test 'already confirmed user should not be able to confirm the account again' do
    user = create_user(confirm: false)
    user.confirmed_at = Time.now
    user.save
    visit_user_confirmation_with_token(user.raw_confirmation_token)

    assert_have_selector '#error_explanation'
    assert_contain 'already confirmed'
  end

  test 'already confirmed user should not be able to confirm the account again neither request confirmation' do
    user = create_user(confirm: false)
    user.confirmed_at = Time.now
    user.save

    visit_user_confirmation_with_token(user.raw_confirmation_token)
    assert_contain 'already confirmed'

    fill_in 'email', with: user.email
    click_button 'Resend confirmation instructions'
    assert_contain 'already confirmed'
  end

  test 'not confirmed user with setup to block without confirmation should not be able to sign in' do
    swap Devise, allow_unconfirmed_access_for: 0.days do
      sign_in_as_user(confirm: false)

      assert_contain 'You have to confirm your email address before continuing'
      refute warden.authenticated?(:user)
    end
  end

  test 'not confirmed user should not see confirmation message if invalid credentials are given' do
    swap Devise, allow_unconfirmed_access_for: 0.days do
      sign_in_as_user(confirm: false) do
        fill_in 'password', with: 'invalid'
      end

      assert_contain 'Invalid Email or password'
      refute warden.authenticated?(:user)
    end
  end

  test 'not confirmed user but configured with some days to confirm should be able to sign in' do
    swap Devise, allow_unconfirmed_access_for: 1.day do
      sign_in_as_user(confirm: false)

      assert_response :success
      assert warden.authenticated?(:user)
    end
  end

  test 'unconfirmed but signed in user should be redirected to their root path' do
    swap Devise, allow_unconfirmed_access_for: 1.day do
      user = sign_in_as_user(confirm: false)

      visit_user_confirmation_with_token(user.raw_confirmation_token)
      assert_contain 'Your email address has been successfully confirmed.'
      assert_current_url '/'
    end
  end

  test 'user should be redirected to sign in page whenever signed in as another resource at same session already' do
    sign_in_as_admin

    user = create_user(confirm: false)
    visit_user_confirmation_with_token(user.raw_confirmation_token)

    assert_current_url '/users/sign_in'
  end

  test 'error message is configurable by resource name' do
    store_translations :en, devise: {
      failure: { user: { unconfirmed: "Not confirmed user" } }
    } do
      sign_in_as_user(confirm: false)
      assert_contain 'Not confirmed user'
    end
  end

  test 'resent confirmation token with valid E-Mail in XML format should return valid response' do
    user = create_user(confirm: false)
    post user_confirmation_path(format: 'xml'), params: { user: { email: user.email } }
    assert_response :success
    assert_equal response.body, {}.to_xml
  end

  test 'resent confirmation token with invalid E-Mail in XML format should return invalid response' do
    create_user(confirm: false)
    post user_confirmation_path(format: 'xml'), params: { user: { email: 'invalid.test@test.com' } }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'confirm account with valid confirmation token in XML format should return valid response' do
    user = create_user(confirm: false)
    get user_confirmation_path(confirmation_token: user.raw_confirmation_token, format: 'xml')
    assert_response :success
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>)
  end

  test 'confirm account with invalid confirmation token in XML format should return invalid response' do
    create_user(confirm: false)
    get user_confirmation_path(confirmation_token: 'invalid_confirmation', format: 'xml')
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'request an account confirmation account with JSON, should return an empty JSON' do
    user = create_user(confirm: false)

    post user_confirmation_path, params: { user: { email: user.email }, format: :json }
    assert_response :success
    assert_equal response.body, {}.to_json
  end

  test "when in paranoid mode and with a valid e-mail, should not say that the e-mail is valid" do
    swap Devise, paranoid: true do
      user = create_user(confirm: false)
      visit new_user_session_path

      click_link "Didn't receive confirmation instructions?"
      fill_in 'email', with: user.email
      click_button 'Resend confirmation instructions'

      assert_contain "If your email address exists in our database, you will receive an email with instructions for how to confirm your email address in a few minutes."
      assert_current_url "/users/sign_in"
    end
  end

  test "when in paranoid mode and with a invalid e-mail, should not say that the e-mail is invalid" do
    swap Devise, paranoid: true do
      visit new_user_session_path

      click_link "Didn't receive confirmation instructions?"
      fill_in 'email', with: "idonthavethisemail@gmail.com"
      click_button 'Resend confirmation instructions'

      assert_not_contain "1 error prohibited this user from being saved:"
      assert_not_contain "Email not found"

      assert_contain "If your email address exists in our database, you will receive an email with instructions for how to confirm your email address in a few minutes."
      assert_current_url "/users/sign_in"
    end
  end
end

class ConfirmationOnChangeTest < Devise::IntegrationTest
  def create_second_admin(options={})
    @admin = nil
    create_admin(options)
  end

  def visit_admin_confirmation_with_token(confirmation_token)
    visit admin_confirmation_path(confirmation_token: confirmation_token)
  end

  test 'admin should be able to request a new confirmation after email changed' do
    admin = create_admin
    admin.update_attributes(email: 'new_test@example.com')

    visit new_admin_session_path
    click_link "Didn't receive confirmation instructions?"

    fill_in 'email', with: admin.unconfirmed_email
    assert_difference "ActionMailer::Base.deliveries.size" do
      click_button 'Resend confirmation instructions'
    end

    assert_current_url '/admin_area/sign_in'
    assert_contain 'You will receive an email with instructions for how to confirm your email address in a few minutes'
  end

  test 'admin with valid confirmation token should be able to confirm email after email changed' do
    admin = create_admin
    admin.update_attributes(email: 'new_test@example.com')
    assert_equal 'new_test@example.com', admin.unconfirmed_email
    visit_admin_confirmation_with_token(admin.raw_confirmation_token)

    assert_contain 'Your email address has been successfully confirmed.'
    assert_current_url '/admin_area/sign_in'
    assert admin.reload.confirmed?
    refute admin.reload.pending_reconfirmation?
  end

  test 'admin with previously valid confirmation token should not be able to confirm email after email changed again' do
    admin = create_admin
    admin.update_attributes(email: 'first_test@example.com')
    assert_equal 'first_test@example.com', admin.unconfirmed_email

    raw_confirmation_token = admin.raw_confirmation_token
    admin = Admin.find(admin.id)

    admin.update_attributes(email: 'second_test@example.com')
    assert_equal 'second_test@example.com', admin.unconfirmed_email

    visit_admin_confirmation_with_token(raw_confirmation_token)
    assert_have_selector '#error_explanation'
    assert_contain(/Confirmation token(.*)invalid/)

    visit_admin_confirmation_with_token(admin.raw_confirmation_token)
    assert_contain 'Your email address has been successfully confirmed.'
    assert_current_url '/admin_area/sign_in'
    assert admin.reload.confirmed?
    refute admin.reload.pending_reconfirmation?
  end

  test 'admin email should be unique also within unconfirmed_email' do
    admin = create_admin
    admin.update_attributes(email: 'new_admin_test@example.com')
    assert_equal 'new_admin_test@example.com', admin.unconfirmed_email

    create_second_admin(email: "new_admin_test@example.com")

    visit_admin_confirmation_with_token(admin.raw_confirmation_token)
    assert_have_selector '#error_explanation'
    assert_contain(/Email.*already.*taken/)
    assert admin.reload.pending_reconfirmation?
  end
end
