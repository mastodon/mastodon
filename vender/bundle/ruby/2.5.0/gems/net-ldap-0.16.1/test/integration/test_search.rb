require_relative '../test_helper'

class TestSearchIntegration < LDAPIntegrationTestCase
  def test_search
    entries = []

    result = @ldap.search(base: "dc=rubyldap,dc=com") do |entry|
      assert_kind_of Net::LDAP::Entry, entry
      entries << entry
    end

    refute entries.empty?
    assert_equal entries, result
  end

  def test_search_without_result
    entries = []

    result = @ldap.search(base: "dc=rubyldap,dc=com", return_result: false) do |entry|
      assert_kind_of Net::LDAP::Entry, entry
      entries << entry
    end

    assert result
    refute_equal entries, result
  end

  def test_search_filter_string
    entries = @ldap.search(base: "dc=rubyldap,dc=com", filter: "(uid=user1)")
    assert_equal 1, entries.size
  end

  def test_search_filter_object
    filter = Net::LDAP::Filter.eq("uid", "user1") | Net::LDAP::Filter.eq("uid", "user2")
    entries = @ldap.search(base: "dc=rubyldap,dc=com", filter: filter)
    assert_equal 2, entries.size
  end

  def test_search_constrained_attributes
    entry = @ldap.search(base: "uid=user1,ou=People,dc=rubyldap,dc=com", attributes: ["cn", "sn"]).first
    assert_equal [:cn, :dn, :sn], entry.attribute_names.sort  # :dn is always included
    assert_empty entry[:mail]
  end

  def test_search_attributes_only
    entry = @ldap.search(base: "uid=user1,ou=People,dc=rubyldap,dc=com", attributes_only: true).first

    assert_empty entry[:cn], "unexpected attribute value: #{entry[:cn]}"
  end

  def test_search_timeout
    entries = []
    events = @service.subscribe "search.net_ldap_connection"

    result = @ldap.search(base: "dc=rubyldap,dc=com", time: 5) do |entry|
      assert_kind_of Net::LDAP::Entry, entry
      entries << entry
    end

    payload, = events.pop
    assert_equal 5, payload[:time]
    assert_equal entries, result
  end

  # http://tools.ietf.org/html/rfc4511#section-4.5.1.4
  def test_search_with_size
    entries = []

    result = @ldap.search(base: "dc=rubyldap,dc=com", size: 1) do |entry|
      assert_kind_of Net::LDAP::Entry, entry
      entries << entry
    end

    assert_equal 1, result.size
    assert_equal entries, result
  end
end
