require_relative "../spec_helper"
require "timecop"

describe "#track with throttle-ish options" do
  it "notifies when throttle goes over the limit without actually throttling requests" do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    Rack::Attack.track("by ip", limit: 1, period: 60) do |request|
      request.ip
    end

    notification_matched = nil
    notification_type = nil

    ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, request|
      notification_matched = request.env["rack.attack.matched"]
      notification_type = request.env["rack.attack.match_type"]
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_nil notification_matched
    assert_nil notification_type

    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    assert_nil notification_matched
    assert_nil notification_type

    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal "by ip", notification_matched
    assert_equal :track, notification_type

    assert_equal 200, last_response.status

    Timecop.travel(60) do
      notification_matched = nil
      notification_type = nil

      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

      assert_nil notification_matched
      assert_nil notification_type

      assert_equal 200, last_response.status
    end
  end
end
