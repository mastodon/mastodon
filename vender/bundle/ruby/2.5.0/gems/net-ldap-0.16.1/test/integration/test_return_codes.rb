require_relative '../test_helper'

# NOTE: These tests depend on the OpenLDAP retcode overlay.
# See: section 12.12 http://www.openldap.org/doc/admin24/overlays.html

class TestReturnCodeIntegration < LDAPIntegrationTestCase
  def test_operations_error
    refute @ldap.search(filter: "cn=operationsError", base: "ou=Retcodes,dc=rubyldap,dc=com")
    assert result = @ldap.get_operation_result

    assert_equal Net::LDAP::ResultCodeOperationsError, result.code
    assert_equal Net::LDAP::ResultStrings[Net::LDAP::ResultCodeOperationsError], result.message
  end

  def test_protocol_error
    refute @ldap.search(filter: "cn=protocolError", base: "ou=Retcodes,dc=rubyldap,dc=com")
    assert result = @ldap.get_operation_result

    assert_equal Net::LDAP::ResultCodeProtocolError, result.code
    assert_equal Net::LDAP::ResultStrings[Net::LDAP::ResultCodeProtocolError], result.message
  end

  def test_time_limit_exceeded
    assert @ldap.search(filter: "cn=timeLimitExceeded", base: "ou=Retcodes,dc=rubyldap,dc=com")
    assert result = @ldap.get_operation_result

    assert_equal Net::LDAP::ResultCodeTimeLimitExceeded, result.code
    assert_equal Net::LDAP::ResultStrings[Net::LDAP::ResultCodeTimeLimitExceeded], result.message
  end

  def test_size_limit_exceeded
    assert @ldap.search(filter: "cn=sizeLimitExceeded", base: "ou=Retcodes,dc=rubyldap,dc=com")
    assert result = @ldap.get_operation_result

    assert_equal Net::LDAP::ResultCodeSizeLimitExceeded, result.code
    assert_equal Net::LDAP::ResultStrings[Net::LDAP::ResultCodeSizeLimitExceeded], result.message
  end
end
