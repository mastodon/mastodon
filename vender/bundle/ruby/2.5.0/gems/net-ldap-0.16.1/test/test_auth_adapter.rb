require 'test_helper'

class TestAuthAdapter < Test::Unit::TestCase
  class FakeSocket
    def initialize(*args)
    end
  end

  def test_undefined_auth_adapter
    conn = Net::LDAP::Connection.new(host: 'ldap.example.com', port: 379, :socket_class => FakeSocket)
    assert_raise Net::LDAP::AuthMethodUnsupportedError, "Unsupported auth method (foo)" do
      conn.bind(method: :foo)
    end
  end
end
