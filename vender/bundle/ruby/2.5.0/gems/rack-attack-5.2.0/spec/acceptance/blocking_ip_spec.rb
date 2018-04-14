require_relative "../spec_helper"

describe "Blocking an IP" do
  before do
    Rack::Attack.blocklist_ip("1.2.3.4")
  end

  it "forbids request if IP matches" do
    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 403, last_response.status
  end

  it "succeeds if IP doesn't match" do
    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    assert_equal 200, last_response.status
  end

  it "notifies when the request is blocked" do
    notified = false
    notification_type = nil

    ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, request|
      notified = true
      notification_type = request.env["rack.attack.match_type"]
    end

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    refute notified

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert notified
    assert_equal :blocklist, notification_type
  end
end
