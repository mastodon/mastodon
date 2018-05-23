require 'test_helper'
require 'private_address_check/tcpsocket_ext'

class TCPSocketExtTest < Minitest::Test
  def test_private_address
    assert_raises PrivateAddressCheck::PrivateConnectionAttemptedError do
      PrivateAddressCheck.only_public_connections do
        TCPSocket.new("localhost", 80)
      end
    end
  end

  def test_public_address
    connected = false
    PrivateAddressCheck.only_public_connections do
      TCPSocket.new("example.com", 80)
      connected = true
    end

    assert connected
  end

  def test_invalid_domain
    assert_raises SocketError do
      PrivateAddressCheck.only_public_connections do
        TCPSocket.new("not_a_domain", 80)
      end
    end
  end
end
