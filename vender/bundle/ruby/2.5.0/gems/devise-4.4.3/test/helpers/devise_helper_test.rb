# frozen_string_literal: true

require 'test_helper'

class DeviseHelperTest < Devise::IntegrationTest
  setup do
    model_labels = { models: { user: "the user" } }
    translations = {
      errors: { messages: { not_saved: {
        one: "Can't save %{resource} because of 1 error",
        other: "Can't save %{resource} because of %{count} errors",
      } } },
      activerecord: model_labels,
      mongoid: model_labels
    }

    I18n.available_locales
    I18n.backend.store_translations(:en, translations)
  end

  teardown do
    I18n.reload!
  end

  test 'test errors.messages.not_saved with single error from i18n' do
    get new_user_registration_path

    fill_in 'password', with: 'new_user123'
    fill_in 'password confirmation', with: 'new_user123'
    click_button 'Sign up'

    assert_have_selector '#error_explanation'
    assert_contain "Can't save the user because of 1 error"
  end

  test 'test errors.messages.not_saved with multiple errors from i18n' do
    # Dirty tracking behavior prevents email validations from being applied:
    #    https://github.com/mongoid/mongoid/issues/756
    (pending "Fails on Mongoid < 2.1"; break) if defined?(Mongoid) && Mongoid::VERSION.to_f < 2.1

    get new_user_registration_path

    fill_in 'email', with: 'invalid_email'
    fill_in 'password', with: 'new_user123'
    fill_in 'password confirmation', with: 'new_user321'
    click_button 'Sign up'

    assert_have_selector '#error_explanation'
    assert_contain "Can't save the user because of 2 errors"
  end
end
