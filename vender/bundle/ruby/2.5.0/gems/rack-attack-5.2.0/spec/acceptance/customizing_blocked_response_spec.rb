require_relative "../spec_helper"

describe "Customizing block responses" do
  before do
    Rack::Attack.blocklist("block 1.2.3.4") do |request|
      request.ip == "1.2.3.4"
    end
  end

  it "can be customized" do
    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 403, last_response.status

    Rack::Attack.blocklisted_response = lambda do |env|
      [503, {}, ["Blocked"]]
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 503, last_response.status
    assert_equal "Blocked", last_response.body
  end

  it "exposes match data" do
    matched = nil
    match_type = nil

    Rack::Attack.blocklisted_response = lambda do |env|
      matched = env['rack.attack.matched']
      match_type = env['rack.attack.match_type']

      [503, {}, ["Blocked"]]
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal "block 1.2.3.4", matched
    assert_equal :blocklist, match_type
  end
end
