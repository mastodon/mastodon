require "spec_helper"

describe Fog::Service do
  class TestService < Fog::Service
    requires :generic_api_key
    recognizes :generic_user

    class Real
      attr_reader :options

      def initialize(opts = {})
        @options = opts
      end
    end

    class Mock
      attr_reader :options

      def initialize(opts = {})
        @options = opts
      end
    end
  end

  class ChildOfTestService < TestService
    class Real; def initialize(*_args); end; end
    class Mock; def initialize(*_args); end; end
  end

  it "properly passes headers" do
    user_agent_hash = {
      "User-Agent" => "Generic Fog Client"
    }
    params = {
      :generic_user => "bob",
      :generic_api_key => "1234",
      :connection_options => {
        :headers => user_agent_hash
      }
    }
    service = TestService.new(params)

    assert_equal user_agent_hash, service.options[:connection_options][:headers]
  end

  describe "when created with a Hash" do
    it "raises for required argument that are missing" do
      assert_raises(ArgumentError) { TestService.new({}) }
    end

    it "converts String keys to be Symbols" do
      service = TestService.new "generic_api_key" => "abc"
      assert_includes service.options.keys, :generic_api_key
    end

    it "removes keys with `nil` values" do
      service = TestService.new :generic_api_key => "abc", :generic_user => nil
      refute_includes service.options.keys, :generic_user
    end

    it "converts number String values with to_i" do
      service = TestService.new :generic_api_key => "3421"
      assert_equal 3421, service.options[:generic_api_key]
    end

    it "converts 'true' String values to TrueClass" do
      service = TestService.new :generic_api_key => "true"
      assert_equal true, service.options[:generic_api_key]
    end

    it "converts 'false' String values to FalseClass" do
      service = TestService.new :generic_api_key => "false"
      assert_equal false, service.options[:generic_api_key]
    end

    it "warns for unrecognised options" do
      bad_options = { :generic_api_key => "abc", :bad_option => "bad value" }
      logger = Minitest::Mock.new
      logger.expect :warning, nil, ["Unrecognized arguments: bad_option"]
      Fog.stub_const :Logger, logger do
        TestService.new(bad_options)
      end
      logger.verify
    end
  end

  describe "when creating and mocking is disabled" do
    it "returns the real service" do
      Fog.stub :mocking?, false do
        service = TestService.new(:generic_api_key => "abc")
        service.must_be_instance_of TestService::Real
      end
    end

    it "TestService::Real has TestService::Collections mixed into the mocked service" do
      Fog.stub :mocking?, false do
        service = TestService.new(:generic_api_key => "abc")
        assert_includes(service.class.ancestors, TestService::Collections)
        assert_includes(service.class.ancestors, Fog::Service::Collections)
        refute_includes(service.class.ancestors, ChildOfTestService::Collections)
      end
    end

    it "ChildOfTestService::Real has ChildOfTestService::Collections and TestService::Collections mixed in" do
      Fog.stub :mocking?, true do
        service = ChildOfTestService.new
        assert_includes(service.class.ancestors, Fog::Service::Collections)
        assert_includes(service.class.ancestors, TestService::Collections)
        assert_includes(service.class.ancestors, ChildOfTestService::Collections)
      end
    end
  end

  describe "when creating and mocking is enabled" do
    it "returns mocked service" do
      Fog.stub :mocking?, true do
        service = TestService.new(:generic_api_key => "abc")
        service.must_be_instance_of TestService::Mock
      end
    end

    it "TestService::Mock has TestService::Collections mixed into the mocked service" do
      Fog.stub :mocking?, true do
        service = TestService.new(:generic_api_key => "abc")
        assert_includes(service.class.ancestors, Fog::Service::Collections)
        assert_includes(service.class.ancestors, TestService::Collections)
        refute_includes(service.class.ancestors, ChildOfTestService::Collections)
      end
    end

    it "ChildOfTestService::Mock has ChildOfTestService::Collections and TestService::Collections mixed in" do
      Fog.stub :mocking?, true do
        service = ChildOfTestService.new
        assert_includes(service.class.ancestors, Fog::Service::Collections)
        assert_includes(service.class.ancestors, TestService::Collections)
        assert_includes(service.class.ancestors, ChildOfTestService::Collections)
      end
    end
  end

  describe "when no credentials are provided" do
    it "uses the global values" do
      @global_credentials = {
        :generic_user => "fog",
        :generic_api_key => "fog"
      }

      Fog.stub :credentials, @global_credentials do
        @service = TestService.new
        assert_equal @service.options, @global_credentials
      end
    end
  end

  describe "when credentials are provided as settings" do
    it "merges the global values into settings" do
      @settings = {
        :generic_user => "fog"
      }
      @global_credentials = {
        :generic_user => "bob",
        :generic_api_key => "fog"
      }

      Fog.stub :credentials, @global_credentials do
        @service = TestService.new(@settings)
        assert_equal @service.options[:generic_user], "fog"
        assert_equal @service.options[:generic_api_key], "fog"
      end
    end
  end

  describe "when config object can configure the service itself" do
    it "ignores the global and its values" do
      @config = MiniTest::Mock.new
      def @config.config_service?;  true; end
      def @config.nil?; false; end
      def @config.==(other); object_id == other.object_id; end

      unexpected_usage = lambda { raise "Accessing global!" }
      Fog.stub :credentials, unexpected_usage do
        @service = TestService.new(@config)
        assert_equal @config, @service.options
      end
    end
  end

  describe "#setup_requirements" do
    before :each do
      @service = FakeService.new
    end

    it "should require collections" do
      assert @service.respond_to?(:collection)
    end

    it "should mock" do
      assert_includes @service.mocked_requests, :request
    end
  end
end
