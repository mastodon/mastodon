require 'test_helper'

class IPAddressTest < Minitest::Test

  def setup
    @valid_ipv4   = "172.16.10.1/24"
    @valid_ipv6   = "2001:db8::8:800:200c:417a/64"
    @valid_mapped = "::13.1.68.3"

    @invalid_ipv4   = "10.0.0.256"
    @invalid_ipv6   = ":1:2:3:4:5:6:7"
    @invalid_mapped = "::1:2.3.4"

    @valid_ipv4_uint32 = [4294967295, # 255.255.255.255
                          167772160,  # 10.0.0.0
                          3232235520, # 192.168.0.0
                          0]

    @invalid_ipv4_uint32 = [4294967296, # 256.0.0.0
                          "A294967295", # Invalid uINT
                          -1]           # Invalid 


    @ipv4class   = IPAddress::IPv4
    @ipv6class   = IPAddress::IPv6
    @mappedclass = IPAddress::IPv6::Mapped
    
    @invalid_ipv4 = ["10.0.0.256",
                     "10.0.0.0.0",
                     "10.0.0",
                     "10.0"]

    @valid_ipv4_range = ["10.0.0.1-254",
                         "10.0.1-254.0",
                         "10.1-254.0.0"]

    @method = Module.method("IPAddress")
  end

  def test_method_IPAddress

    assert_instance_of @ipv4class, @method.call(@valid_ipv4) 
    assert_instance_of @ipv6class, @method.call(@valid_ipv6) 
    assert_instance_of @mappedclass, @method.call(@valid_mapped)

    assert_raises(ArgumentError) {@method.call(@invalid_ipv4)}
    assert_raises(ArgumentError) {@method.call(@invalid_ipv6)}
    assert_raises(ArgumentError) {@method.call(@invalid_mapped)}

    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[0]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[1]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[2]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[3]) 

    assert_raises(ArgumentError) {@method.call(@invalid_ipv4_uint32[0])}
    assert_raises(ArgumentError) {@method.call(@invalid_ipv4_uint32[1])}
    assert_raises(ArgumentError) {@method.call(@invalid_ipv4_uint32[2])}

  end

  def test_module_method_valid?
    assert_equal true, IPAddress::valid?("10.0.0.1")
    assert_equal true, IPAddress::valid?("10.0.0.0")
    assert_equal true, IPAddress::valid?("2002::1")
    assert_equal true, IPAddress::valid?("dead:beef:cafe:babe::f0ad")
    assert_equal false, IPAddress::valid?("10.0.0.256")
    assert_equal false, IPAddress::valid?("10.0.0.0.0")
    assert_equal false, IPAddress::valid?("10.0.0")
    assert_equal false, IPAddress::valid?("10.0")
    assert_equal false, IPAddress::valid?("2002:::1")
    assert_equal false, IPAddress::valid?("2002:516:2:200")

  end

  def test_module_method_valid_ipv4_netmark?
    assert_equal true, IPAddress::valid_ipv4_netmask?("255.255.255.0")
    assert_equal false, IPAddress::valid_ipv4_netmask?("10.0.0.1")
  end

end


