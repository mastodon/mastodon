require_relative '../test_helper'

class TestBindIntegration < LDAPIntegrationTestCase
  def test_binds_without_open
    events = @service.subscribe "bind.net_ldap_connection"

    @ldap.search(filter: "uid=user1", base: "ou=People,dc=rubyldap,dc=com", ignore_server_caps: true)
    @ldap.search(filter: "uid=user1", base: "ou=People,dc=rubyldap,dc=com", ignore_server_caps: true)

    assert_equal 2, events.size
  end

  def test_binds_with_open
    events = @service.subscribe "bind.net_ldap_connection"

    @ldap.open do
      @ldap.search(filter: "uid=user1", base: "ou=People,dc=rubyldap,dc=com", ignore_server_caps: true)
      @ldap.search(filter: "uid=user1", base: "ou=People,dc=rubyldap,dc=com", ignore_server_caps: true)
    end

    assert_equal 1, events.size
  end

  # NOTE: query for two or more entries so that the socket must be read
  # multiple times.
  # See The Problem: https://github.com/ruby-ldap/ruby-net-ldap/issues/136

  def test_nested_search_without_open
    entries = []
    nested_entry = nil

    @ldap.search(filter: "(|(uid=user1)(uid=user2))", base: "ou=People,dc=rubyldap,dc=com") do |entry|
      entries << entry.uid.first
      nested_entry ||= @ldap.search(filter: "uid=user3", base: "ou=People,dc=rubyldap,dc=com").first
    end

    assert_equal "user3", nested_entry.uid.first
    assert_equal %w(user1 user2), entries
  end

  def test_nested_search_with_open
    entries = []
    nested_entry = nil

    @ldap.open do
      @ldap.search(filter: "(|(uid=user1)(uid=user2))", base: "ou=People,dc=rubyldap,dc=com") do |entry|
        entries << entry.uid.first
        nested_entry ||= @ldap.search(filter: "uid=user3", base: "ou=People,dc=rubyldap,dc=com").first
      end
    end

    assert_equal "user3", nested_entry.uid.first
    assert_equal %w(user1 user2), entries
  end

  def test_nested_add_with_open
    entries = []
    nested_entry = nil

    dn = "uid=nested-open-added-user1,ou=People,dc=rubyldap,dc=com"
    attrs = {
      objectclass: %w(top inetOrgPerson organizationalPerson person),
      uid:  "nested-open-added-user1",
      cn:   "nested-open-added-user1",
      sn:   "nested-open-added-user1",
      mail: "nested-open-added-user1@rubyldap.com",
    }

    @ldap.authenticate "cn=admin,dc=rubyldap,dc=com", "passworD1"
    @ldap.delete dn: dn

    @ldap.open do
      @ldap.search(filter: "(|(uid=user1)(uid=user2))", base: "ou=People,dc=rubyldap,dc=com") do |entry|
        entries << entry.uid.first

        nested_entry ||= begin
          assert @ldap.add(dn: dn, attributes: attrs), @ldap.get_operation_result.inspect
          @ldap.search(base: dn, scope: Net::LDAP::SearchScope_BaseObject).first
        end
      end
    end

    assert_equal %w(user1 user2), entries
    assert_equal "nested-open-added-user1", nested_entry.uid.first
  ensure
    @ldap.delete dn: dn
  end
end
