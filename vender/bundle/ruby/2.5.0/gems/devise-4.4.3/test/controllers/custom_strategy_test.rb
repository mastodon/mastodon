# frozen_string_literal: true

require 'test_helper'
require 'ostruct'
require 'warden/strategies/base'
require 'devise/test_helpers'

class CustomStrategyController < ActionController::Base
  def new
    warden.authenticate!(:custom_strategy)
  end
end

# These tests are to prove that a warden strategy can successfully
# return a custom response, including a specific status code and
# custom http response headers. This does work in production,
# however, at the time of writing this, the Devise test helpers do
# not recognise the custom response and proceed to calling the
# Failure App. This makes it impossible to write tests for a
# strategy that return a custom response with Devise.
class CustomStrategy < Warden::Strategies::Base
  def authenticate!
    custom_headers = { "X-FOO" => "BAR" }
    response = Rack::Response.new("BAD REQUEST", 400, custom_headers)
    custom! response.finish
  end
end

class CustomStrategyTest < Devise::ControllerTestCase
  tests CustomStrategyController

  include Devise::Test::ControllerHelpers

  setup do
    Warden::Strategies.add(:custom_strategy, CustomStrategy)
  end

  teardown do
    Warden::Strategies._strategies.delete(:custom_strategy)
  end

  test "custom strategy can return its own status code" do
    ret = get :new

    # check the returned rack array
    # assert ret.is_a?(Array)
    # assert_equal 400, ret.first
    assert ret.is_a?(ActionDispatch::TestResponse)

    # check the saved response as well. This is purely so that the response is available to the testing framework
    # for verification. In production, the above array would be delivered directly to Rack.
    assert_response 400
  end

  test "custom strategy can return custom headers" do
    ret = get :new

    # check the returned rack array
    # assert ret.is_a?(Array)
    # assert_equal ret.third['X-FOO'], 'BAR'
    assert ret.is_a?(ActionDispatch::TestResponse)

    # check the saved response headers as well.
    assert_equal response.headers['X-FOO'], 'BAR'
  end
end
