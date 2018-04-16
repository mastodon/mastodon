require_relative '../test_helper'

class TestDeleteIntegration < LDAPIntegrationTestCase
  def setup
    super
    @ldap.authenticate "cn=admin,dc=rubyldap,dc=com", "passworD1"

    @dn = "uid=delete-user1,ou=People,dc=rubyldap,dc=com"

    attrs = {
      objectclass: %w(top inetOrgPerson organizationalPerson person),
      uid:  "delete-user1",
      cn:   "delete-user1",
      sn:   "delete-user1",
      mail: "delete-user1@rubyldap.com",
    }
    unless @ldap.search(base: @dn, scope: Net::LDAP::SearchScope_BaseObject)
      assert @ldap.add(dn: @dn, attributes: attrs), @ldap.get_operation_result.inspect
    end
    assert @ldap.search(base: @dn, scope: Net::LDAP::SearchScope_BaseObject)
  end

  def test_delete
    assert @ldap.delete(dn: @dn), @ldap.get_operation_result.inspect
    refute @ldap.search(base: @dn, scope: Net::LDAP::SearchScope_BaseObject)

    result = @ldap.get_operation_result
    assert_equal Net::LDAP::ResultCodeNoSuchObject, result.code
    assert_equal Net::LDAP::ResultStrings[Net::LDAP::ResultCodeNoSuchObject], result.message
  end
end
