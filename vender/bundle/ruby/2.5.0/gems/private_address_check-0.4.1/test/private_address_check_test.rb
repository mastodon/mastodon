require 'test_helper'

class PrivateAddressCheckTest < Minitest::Test
  def test_private_address_for_public_addresses
    refute PrivateAddressCheck.private_address?("192.30.253.113")
    refute PrivateAddressCheck.private_address?("8.8.8.8")
  end

  def test_private_address_for_rfc1918_addresses
    assert PrivateAddressCheck.private_address?("10.10.10.2")
    assert PrivateAddressCheck.private_address?("172.16.2.10")
    assert PrivateAddressCheck.private_address?("192.168.1.10")
  end

  def test_private_address_for_rfc4193_addresses
    assert PrivateAddressCheck.private_address?("fc00::a")
    assert PrivateAddressCheck.private_address?("fd00::2")
  end

  def test_private_address_for_loopback_addresses
    assert PrivateAddressCheck.private_address?("127.0.0.1")
    assert PrivateAddressCheck.private_address?("127.2.2.2")
    assert PrivateAddressCheck.private_address?("::1")
  end

  def test_private_address_for_link_local_addresses
    assert PrivateAddressCheck.private_address?("169.254.2.5")
  end

  def test_private_hostname_for_public_addresses
    refute PrivateAddressCheck.resolves_to_private_address?("github.com")
    refute PrivateAddressCheck.resolves_to_private_address?("example.com")
  end

  def test_private_hostname_for_private_addresses
    assert PrivateAddressCheck.resolves_to_private_address?("localhost")
  end

  def test_private_address_for_malformed_addresses
    assert PrivateAddressCheck.resolves_to_private_address?("127.1")
  end
end
