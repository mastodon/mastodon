require_relative "../spec_helper"

describe "Cache store config when throttling without Rails" do
  before do
    Rack::Attack.throttle("by ip", limit: 1, period: 60) do |request|
      request.ip
    end
  end

  it "gives semantic error if no store was configured" do
    assert_raises(Rack::Attack::MissingStoreError) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    end
  end

  it "gives semantic error if incompatible store was configured" do
    Rack::Attack.cache.store = Object.new

    assert_raises(Rack::Attack::MisconfiguredStoreError) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    end
  end

  it "works with any object that responds to #increment" do
    basic_store_class = Class.new do
      attr_accessor :counts

      def initialize
        @counts = {}
      end

      def increment(key, count, options)
        @counts[key] ||= 0
        @counts[key] += 1
      end
    end

    Rack::Attack.cache.store = basic_store_class.new

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 200, last_response.status

    get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

    assert_equal 429, last_response.status
  end
end
