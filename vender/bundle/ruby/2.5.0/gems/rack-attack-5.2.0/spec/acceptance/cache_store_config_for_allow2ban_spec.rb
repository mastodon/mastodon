require_relative "../spec_helper"

describe "Cache store config when using allow2ban" do
  before do
    Rack::Attack.blocklist("allow2ban pentesters") do |request|
      Rack::Attack::Allow2Ban.filter(request.ip, maxretry: 2, findtime: 30, bantime: 60) do
        request.path.include?("scarce-resource")
      end
    end
  end

  it "gives semantic error if no store was configured" do
    assert_raises(Rack::Attack::MissingStoreError) do
      get "/scarce-resource"
    end
  end

  it "gives semantic error if store is missing #read method" do
    basic_store_class = Class.new do
      def write(key, value)
      end

      def increment(key, count, options = {})
      end
    end

    Rack::Attack.cache.store = basic_store_class.new

    raised_exception = assert_raises(Rack::Attack::MisconfiguredStoreError) do
      get "/scarce-resource"
    end

    assert_equal "Store needs to respond to #read", raised_exception.message
  end

  it "gives semantic error if store is missing #write method" do
    basic_store_class = Class.new do
      def read(key)
      end

      def increment(key, count, options = {})
      end
    end

    Rack::Attack.cache.store = basic_store_class.new

    raised_exception = assert_raises(Rack::Attack::MisconfiguredStoreError) do
      get "/scarce-resource"
    end

    assert_equal "Store needs to respond to #write", raised_exception.message
  end

  it "gives semantic error if store is missing #increment method" do
    basic_store_class = Class.new do
      def read(key)
      end

      def write(key, value)
      end
    end

    Rack::Attack.cache.store = basic_store_class.new

    raised_exception = assert_raises(Rack::Attack::MisconfiguredStoreError) do
      get "/scarce-resource"
    end

    assert_equal "Store needs to respond to #increment", raised_exception.message
  end

  it "works with any object that responds to #read, #write and #increment" do
    basic_store_class = Class.new do
      attr_accessor :backend

      def initialize
        @backend = {}
      end

      def read(key)
        @backend[key]
      end

      def write(key, value, options = {})
        @backend[key] = value
      end

      def increment(key, count, options = {})
        @backend[key] ||= 0
        @backend[key] += 1
      end
    end

    Rack::Attack.cache.store = basic_store_class.new

    get "/"
    assert_equal 200, last_response.status

    get "/scarce-resource"
    assert_equal 200, last_response.status

    get "/scarce-resource"
    assert_equal 200, last_response.status

    get "/scarce-resource"
    assert_equal 403, last_response.status

    get "/"
    assert_equal 403, last_response.status
  end
end
