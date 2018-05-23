# frozen_string_literal: true

require 'test_helper'

class RegisterableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_equal Devise::Models::Registerable.required_fields(User), []
  end
end
