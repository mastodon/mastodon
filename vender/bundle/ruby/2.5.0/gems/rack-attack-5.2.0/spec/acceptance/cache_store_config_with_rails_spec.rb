require_relative "../spec_helper"
require "minitest/stub_const"
require "ostruct"

describe "Cache store config with Rails" do
  before do
    Rack::Attack.throttle("by ip", limit: 1, period: 60) do |request|
      request.ip
    end
  end

  it "fails when Rails.cache is not set" do
    Object.stub_const(:Rails, OpenStruct.new(cache: nil)) do
      assert_raises(Rack::Attack::MissingStoreError) do
        get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      end
    end
  end

  it "works when Rails.cache is set" do
    Object.stub_const(:Rails, OpenStruct.new(cache: ActiveSupport::Cache::MemoryStore.new)) do
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

      assert_equal 200, last_response.status

      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"

      assert_equal 429, last_response.status
    end
  end
end
