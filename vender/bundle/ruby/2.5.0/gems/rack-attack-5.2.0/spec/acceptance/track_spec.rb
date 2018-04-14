require_relative "../spec_helper"

describe "#track" do
  it "notifies when track block returns true" do
    Rack::Attack.track("ip 1.2.3.4") do |request|
      request.ip == "1.2.3.4"
    end

    notification_matched = nil
    notification_type = nil

    ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, request|
      notification_matched = request.env["rack.attack.matched"]
      notification_type = request.env["rack.attack.match_type"]
    end

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    assert_nil notification_matched
    assert_nil notification_type

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal "ip 1.2.3.4", notification_matched
    assert_equal :track, notification_type
  end
end
