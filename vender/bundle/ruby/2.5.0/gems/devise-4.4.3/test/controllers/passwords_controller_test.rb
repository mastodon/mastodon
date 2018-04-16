# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < Devise::ControllerTestCase
  tests Devise::PasswordsController
  include Devise::Test::ControllerHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user.tap(&:confirm)
    @raw  = @user.send_reset_password_instructions
  end

  def put_update_with_params
    put :update, params: { "user" => {
        "reset_password_token" => @raw, "password" => "1234567", "password_confirmation" => "1234567"
      }
    }
  end

  test 'redirect to after_sign_in_path_for if after_resetting_password_path_for is not overridden' do
    put_update_with_params
    assert_redirected_to "http://test.host/"
  end

  test 'redirect accordingly if after_resetting_password_path_for is overridden' do
    custom_path = "http://custom.path/"
    Devise::PasswordsController.any_instance.stubs(:after_resetting_password_path_for).with(@user).returns(custom_path)

    put_update_with_params
    assert_redirected_to custom_path
  end
end
