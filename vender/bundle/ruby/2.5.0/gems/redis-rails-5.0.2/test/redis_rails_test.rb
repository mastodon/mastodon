require "test_helper"

describe Redis::Rails do
  it "must require ActiveSupport dependency" do
    assert defined?(ActiveSupport::Cache::RedisStore)
  end

  it "must require ActionPack dependency" do
    assert defined?(ActionDispatch::Session::RedisStore)
  end
end
