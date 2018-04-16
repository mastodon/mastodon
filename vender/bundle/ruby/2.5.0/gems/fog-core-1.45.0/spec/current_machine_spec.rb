require "spec_helper"

describe Fog::CurrentMachine do
  before do
    @was_mocking = Fog.mock?
    Fog.mock!

    @old_excon_defaults_mock = Excon.defaults[:mock]
    Excon.defaults[:mock] = true
  end

  after do
    Fog.unmock! unless @was_mocking

    Fog::CurrentMachine.ip_address = nil
    Excon.stubs.clear
    Excon.defaults[:mock] = @old_excon_defaults_mock
  end

  describe "ip_address" do
    it "should be thread safe" do

      (1..10).map do
        Thread.new do
          Excon.stub({ :method => :get, :path => "/" }, { :body => "" })
          Fog::CurrentMachine.ip_address
        end
      end.each(&:join)
    end

    it "should remove trailing endline characters" do
      Excon.stub({ :method => :get, :path => "/" }, { :body => "192.168.0.1\n" })
      assert_equal "192.168.0.1", Fog::CurrentMachine.ip_address
    end
  end
end
