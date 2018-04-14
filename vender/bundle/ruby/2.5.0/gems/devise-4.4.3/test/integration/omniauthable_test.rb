# frozen_string_literal: true

require 'test_helper'


class OmniauthableIntegrationTest < Devise::IntegrationTest
  FACEBOOK_INFO = {
    "id" => '12345',
    "link" => 'http://facebook.com/josevalim',
    "email" => 'user@example.com',
    "first_name" => 'Jose',
    "last_name" => 'Valim',
    "website" => 'http://blog.plataformatec.com.br'
  }

  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] = {
      "uid" => '12345',
      "provider" => 'facebook',
      "user_info" => {"nickname" => 'josevalim'},
      "credentials" => {"token" => 'plataformatec'},
      "extra" => {"user_hash" => FACEBOOK_INFO}
    }
    OmniAuth.config.add_camelization 'facebook', 'FaceBook'
  end

  teardown do
    OmniAuth.config.camelizations.delete('facebook')
    OmniAuth.config.test_mode = false
  end

  def stub_action!(name)
    Users::OmniauthCallbacksController.class_eval do
      alias_method :__old_facebook, :facebook
      alias_method :facebook, name
    end
    yield
  ensure
    Users::OmniauthCallbacksController.class_eval do
      alias_method :facebook, :__old_facebook
    end
  end

  test "omniauth sign in should not run model validations" do
    stub_action!(:sign_in_facebook) do
      create_user
      visit "/users/sign_in"
      click_link "Sign in with FaceBook"
      assert warden.authenticated?(:user)

      refute User.validations_performed
    end
  end

  test "can access omniauth.auth in the env hash" do
    visit "/users/sign_in"
    click_link "Sign in with FaceBook"

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal "12345",         json["uid"]
    assert_equal "facebook",      json["provider"]
    assert_equal "josevalim",     json["user_info"]["nickname"]
    assert_equal FACEBOOK_INFO,   json["extra"]["user_hash"]
    assert_equal "plataformatec", json["credentials"]["token"]
  end

  test "cleans up session on sign up" do
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with FaceBook"
    end

    assert session["devise.facebook_data"]

    assert_difference "User.count" do
      visit "/users/sign_up"
      fill_in "Password", with: "12345678"
      fill_in "Password confirmation", with: "12345678"
      click_button "Sign up"
    end

    assert_current_url "/"
    assert_contain "You have signed up successfully."
    assert_contain "Hello User user@example.com"
    refute session["devise.facebook_data"]
  end

  test "cleans up session on cancel" do
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with FaceBook"
    end

    assert session["devise.facebook_data"]
    visit "/users/cancel"
    assert !session["devise.facebook_data"]
  end

  test "cleans up session on sign in" do
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with FaceBook"
    end

    assert session["devise.facebook_data"]
    sign_in_as_user
    assert !session["devise.facebook_data"]
  end

  test "sign in and send remember token if configured" do
    visit "/users/sign_in"
    click_link "Sign in with FaceBook"
    assert_nil warden.cookies["remember_user_token"]

    stub_action!(:sign_in_facebook) do
      create_user
      visit "/users/sign_in"
      click_link "Sign in with FaceBook"
      assert warden.authenticated?(:user)
      assert warden.cookies["remember_user_token"]
    end
  end

  test "generates a proper link when SCRIPT_NAME is set" do
    header 'SCRIPT_NAME', '/q'
    visit "/users/sign_in"
    assert_select "a", href: "/q/users/auth/facebook"
  end

  test "handles callback error parameter according to the specification" do
    OmniAuth.config.mock_auth[:facebook] = :access_denied
    visit "/users/auth/facebook/callback?error=access_denied"
    assert_current_url "/users/sign_in"
    assert_contain 'Could not authenticate you from FaceBook because "Access denied".'
  end

  test "handles other exceptions from OmniAuth" do
    OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

    visit "/users/sign_in"
    click_link "Sign in with FaceBook"

    assert_current_url "/users/sign_in"
    assert_contain 'Could not authenticate you from FaceBook because "Invalid credentials".'
  end
end
