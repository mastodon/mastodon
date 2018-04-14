require_relative "../spec_helper"
require "timecop"

describe "#throttle" do
  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  it "allows one request per minute by IP" do
    Rack::Attack.throttle("by ip", limit: 1, period: 60) do |request|
      request.ip
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 429, last_response.status
    assert_equal "60", last_response.headers["Retry-After"]
    assert_equal "Retry later\n", last_response.body

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    assert_equal 200, last_response.status

    Timecop.travel(60) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

      assert_equal 200, last_response.status
    end
  end

  it "supports limit to be dynamic" do
    # Could be used to have different rate limits for authorized
    # vs general requests
    limit_proc = lambda do |request|
      if request.env["X-APIKey"] == "private-secret"
        2
      else
        1
      end
    end

    Rack::Attack.throttle("by ip", limit: limit_proc, period: 60) do |request|
      request.ip
    end

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    assert_equal 429, last_response.status

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
    assert_equal 429, last_response.status
  end

  it "supports period to be dynamic" do
    # Could be used to have different rate limits for authorized
    # vs general requests
    period_proc = lambda do |request|
      if request.env["X-APIKey"] == "private-secret"
        10
      else
        30
      end
    end

    Rack::Attack.throttle("by ip", limit: 1, period: period_proc) do |request|
      request.ip
    end

    # Using Time#at to align to start/end of periods exactly
    # to achieve consistenty in different test runs

    Timecop.travel(Time.at(0)) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      assert_equal 200, last_response.status

      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      assert_equal 429, last_response.status
    end

    Timecop.travel(Time.at(10)) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      assert_equal 429, last_response.status
    end

    Timecop.travel(Time.at(30)) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      assert_equal 200, last_response.status
    end

    Timecop.travel(Time.at(0)) do
      get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
      assert_equal 200, last_response.status

      get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
      assert_equal 429, last_response.status
    end

    Timecop.travel(Time.at(10)) do
      get "/", {}, "REMOTE_ADDR" => "5.6.7.8", "X-APIKey" => "private-secret"
      assert_equal 200, last_response.status
    end
  end

  it "notifies when the request is throttled" do
    Rack::Attack.throttle("by ip", limit: 1, period: 60) do |request|
      request.ip
    end

    notification_matched = nil
    notification_type = nil
    notification_data = nil
    notification_discriminator = nil

    ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, request|
      notification_matched = request.env["rack.attack.matched"]
      notification_type = request.env["rack.attack.match_type"]
      notification_data = request.env['rack.attack.match_data']
      notification_discriminator = request.env['rack.attack.match_discriminator']
    end

    get "/", {}, "REMOTE_ADDR" => "5.6.7.8"

    assert_equal 200, last_response.status
    assert_nil notification_matched
    assert_nil notification_type
    assert_nil notification_data
    assert_nil notification_discriminator

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 200, last_response.status
    assert_nil notification_matched
    assert_nil notification_type
    assert_nil notification_data
    assert_nil notification_discriminator

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 429, last_response.status
    assert_equal "by ip", notification_matched
    assert_equal :throttle, notification_type
    assert_equal 60, notification_data[:period]
    assert_equal 1, notification_data[:limit]
    assert_equal 2, notification_data[:count]
    assert_equal "1.2.3.4", notification_discriminator
  end
end
