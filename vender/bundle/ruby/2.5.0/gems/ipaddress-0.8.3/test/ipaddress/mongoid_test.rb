require 'test_helper'
require 'ipaddress/mongoid'
 
class MongoidTest < Minitest::Test

  def setup
    @valid_host4               = "172.16.10.1"
    @valid_host6               = "2001:0db8:0000:0000:0008:0800:200c:417a"
    @valid_host6_compressed    = IPAddress::IPv6.compress(@valid_host6)
    @valid_network4            = "#{@valid_host4}/24"
    @valid_network6            = "#{@valid_host6}/96"
    @valid_network6_compressed = "#{@valid_host6_compressed}/96"
    @host4                     = IPAddress.parse(@valid_host4)
    @host6                     = IPAddress.parse(@valid_host6)
    @network4                  = IPAddress.parse(@valid_network4)
    @network6                  = IPAddress.parse(@valid_network6)
    @invalid_values            = [nil, "", "invalid"]
  end

  def test_mongoize
    # Instance method should be delegated to class method
    assert_equal @host4.mongoize,    IPAddress.mongoize(@host4)
    assert_equal @network4.mongoize, IPAddress.mongoize(@network4)

    # Hosts addresses should be stored without prefix
    assert_equal @valid_host4, IPAddress.mongoize(@host4)
    assert_equal @valid_host6, IPAddress.mongoize(@host6)
    assert_equal @valid_host4, IPAddress.mongoize("#{@host4}/32")
    assert_equal @valid_host6, IPAddress.mongoize("#{@host6}/128")

    # Network addresses should be stored with their prefix
    assert_equal @valid_network4, IPAddress.mongoize(@network4)
    assert_equal @valid_network6, IPAddress.mongoize(@network6)

    # IPv6 addresses should always be stored uncompressed
    assert_equal @valid_host6,    IPAddress.mongoize(@valid_host6_compressed)
    assert_equal @valid_network6, IPAddress.mongoize(@valid_network6_compressed)

    @invalid_values.each do |invalid_value|
      # Invalid addresses should serialize to nil
      assert_equal nil, IPAddress.mongoize(invalid_value)
    end
  end

  def test_demongoize
    # Valid stored values should be loaded with expected IPAddress type
    assert_instance_of IPAddress::IPv4, IPAddress.demongoize(@valid_host4)
    assert_instance_of IPAddress::IPv6, IPAddress.demongoize(@valid_host6)
    assert_instance_of IPAddress::IPv4, IPAddress.demongoize(@valid_network4)
    assert_instance_of IPAddress::IPv6, IPAddress.demongoize(@valid_network6)

    # Valid stored values should be loaded as the original IPAddress object
    assert_equal @host4,    IPAddress.demongoize(@valid_host4)
    assert_equal @host6,    IPAddress.demongoize(@valid_host6)
    assert_equal @network4, IPAddress.demongoize(@valid_network4)
    assert_equal @network6, IPAddress.demongoize(@valid_network6)

    @invalid_values.each do |invalid_value|
      # Invalid stored value should be loaded as nil
      assert_equal nil, IPAddress.demongoize(invalid_value)
    end
  end

  def test_evolve
    # evolve should delegate to mongoize
    assert_equal IPAddress.mongoize(@valid_host4),    IPAddress.evolve(@valid_host4)
    assert_equal IPAddress.mongoize(@valid_network4), IPAddress.evolve(@valid_network4)
  end

end