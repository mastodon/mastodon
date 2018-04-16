require_relative '../test_helper'

class TestAddIntegration < LDAPIntegrationTestCase
  def setup
    super
    @ldap.authenticate "cn=admin,dc=rubyldap,dc=com", "passworD1"

    @dn = "uid=added-user1,ou=People,dc=rubyldap,dc=com"
  end

  def test_add
    attrs = {
      objectclass: %w(top inetOrgPerson organizationalPerson person),
      uid:  "added-user1",
      cn:   "added-user1",
      sn:   "added-user1",
      mail: "added-user1@rubyldap.com",
    }

    assert @ldap.add(dn: @dn, attributes: attrs), @ldap.get_operation_result.inspect

    assert result = @ldap.search(base: @dn, scope: Net::LDAP::SearchScope_BaseObject).first
  end

  def teardown
    @ldap.delete dn: @dn
  end
end
