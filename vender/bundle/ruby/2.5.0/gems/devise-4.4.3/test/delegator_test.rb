# frozen_string_literal: true

require 'test_helper'

class DelegatorTest < ActiveSupport::TestCase
  def delegator
    Devise::Delegator.new
  end

  test 'failure_app returns default failure app if no warden options in env' do
    assert_equal Devise::FailureApp, delegator.failure_app({})
  end

  test 'failure_app returns default failure app if no scope in warden options' do
    assert_equal Devise::FailureApp, delegator.failure_app({"warden.options" => {}})
  end

  test 'failure_app returns associated failure app by scope in the given environment' do
    assert_kind_of Proc, delegator.failure_app({"warden.options" => {scope: "manager"}})
  end
end
