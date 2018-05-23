# frozen_string_literal: true

require 'test_helper'

class TestIntegrationsHelpersTest < Devise::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test '#sign_in signs in the resource directly' do
    sign_in(create_user)

    visit '/'
    assert warden.authenticated?(:user)
  end

  test '#sign_outs signs out in the resource directly' do
    user = create_user
    sign_in user
    sign_out user

    visit '/'
    refute warden.authenticated?(:user)
  end

  test '#sign_out does not signs out other scopes' do
    sign_in(create_user)
    sign_in(create_admin)
    sign_out :user

    visit '/'

    refute warden.authenticated?(:user)
    assert warden.authenticated?(:admin)
  end
end
