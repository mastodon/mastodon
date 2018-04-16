require "spec_helper"

describe "Fog mocking" do
  before do
    @fog_was_mocked = Fog.mock?
    Fog.unmock! if @fog_was_mocked
  end

  after do
    Fog.mock! if @fog_was_mocked
  end

  describe "Fog.mock!" do
    it "Fog.mock! returns true" do
      assert_equal true, Fog.mock!
    end

    it "Fog.mock? without Fog.mock! returns false" do
      assert_equal false, Fog.mock?
    end

    it "Fog.mock? with Fog.mock!" do
      Fog.mock!
      assert_equal true, Fog.mock?
    end

    it "Fog.mocking? without Fog.mock!" do
      assert_equal false, Fog.mocking?
    end

    it "Fog.mocking? with Fog.mock!" do
      Fog.mock!
      assert_equal true, Fog.mocking?
    end
  end

  describe "Fog::Mock.delay" do
    it "Fog::Mock.delay defaults to 0" do
      assert_equal 1, Fog::Mock.delay
    end

    it "handles reassignment" do
      Fog::Mock.delay = 2
      assert_equal 2, Fog::Mock.delay

      Fog::Mock.delay = 1
      assert_equal 1, Fog::Mock.delay
    end

    it "raises when given an illegal delay" do
      assert_raises(ArgumentError) do
        Fog::Mock.delay = -1
      end
    end
  end

  describe "Fog::Mock.random_ip" do
    it "defaults to ipv4" do
      assert IPAddr.new(Fog::Mock.random_ip).ipv4?
    end

    it "supports explicit request for v4" do
      assert IPAddr.new(Fog::Mock.random_ip(:version => :v4)).ipv4?
    end

    it "supports explicit request for v6" do
      assert IPAddr.new(Fog::Mock.random_ip(:version => :v6)).ipv6?
    end

    it "raises when supplied an illegal IP version" do
      assert_raises(ArgumentError) do
        IPAddr.new(Fog::Mock.random_ip(:version => :v5)).ipv4?
      end
    end
  end

  describe "Fog::Mock.not_implemented" do
    it "raises MockNotImplemented when called" do
      assert_raises(Fog::Errors::MockNotImplemented) do
        Fog::Mock.not_implemented
      end
    end
  end
end
