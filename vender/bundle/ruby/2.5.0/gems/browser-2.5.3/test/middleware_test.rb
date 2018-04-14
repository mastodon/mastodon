# frozen_string_literal: true

require "test_helper"
require "browser/rails"
require "sample_app"

class MiddlewareTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rails.application
  end

  test "redirects with 302" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 6", "HTTP_ACCEPT" => "text/html"
    assert_equal 302, last_response.status
  end

  test "redirects ie6 to upgrade path" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 6", "HTTP_ACCEPT" => "text/html"
    follow_redirect!

    assert_equal "UPGRADE: ie6", last_response.body
  end

  test "redirects ie7 to upgrade path" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 7", "HTTP_ACCEPT" => "text/html"
    follow_redirect!

    assert_equal "UPGRADE: ie7", last_response.body
  end

  test "redirects ie8 and returns 404" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 8", "HTTP_ACCEPT" => "text/html"
    follow_redirect!

    assert_equal 404, last_response.status
  end

  test "redirects ie8 with wildcard http accept" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 8", "HTTP_ACCEPT" => "*/*"
    follow_redirect!

    assert_equal 404, last_response.status
  end

  test "ignores non-html requests" do
    get "/", {}, "HTTP_USER_AGENT" => "MSIE 6", "HTTP_ACCEPT" => "image/png"

    assert_equal 200, last_response.status
  end
end
