require_relative "../spec_helper"

describe "Customizing throttled response" do
  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    Rack::Attack.throttle("by ip", limit: 1, period: 60) do |request|
      request.ip
    end
  end

  it "can be customized" do
    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 429, last_response.status

    Rack::Attack.throttled_response = lambda do |env|
      [503, {}, ["Throttled"]]
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 503, last_response.status
    assert_equal "Throttled", last_response.body
  end

  it "exposes match data" do
    matched = nil
    match_type = nil
    match_data = nil
    match_discriminator = nil

    Rack::Attack.throttled_response = lambda do |env|
      matched = env['rack.attack.matched']
      match_type = env['rack.attack.match_type']
      match_data = env['rack.attack.match_data']
      match_discriminator = env['rack.attack.match_discriminator']

      [429, {}, ["Throttled"]]
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal "by ip", matched
    assert_equal :throttle, match_type
    assert_equal 60, match_data[:period]
    assert_equal 1, match_data[:limit]
    assert_equal 2, match_data[:count]
    assert_equal "1.2.3.4", match_discriminator

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    assert_equal 3, match_data[:count]
  end
end
