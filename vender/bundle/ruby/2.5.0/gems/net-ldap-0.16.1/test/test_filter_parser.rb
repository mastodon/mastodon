# encoding: utf-8
require_relative 'test_helper'

class TestFilterParser < Test::Unit::TestCase
  def test_ascii
    assert_kind_of Net::LDAP::Filter, Net::LDAP::Filter::FilterParser.parse("(cn=name)")
  end

  def test_multibyte_characters
    assert_kind_of Net::LDAP::Filter, Net::LDAP::Filter::FilterParser.parse("(cn=名前)")
  end

  def test_brackets
    assert_kind_of Net::LDAP::Filter, Net::LDAP::Filter::FilterParser.parse("(cn=[{something}])")
  end

  def test_slash
    assert_kind_of Net::LDAP::Filter, Net::LDAP::Filter::FilterParser.parse("(departmentNumber=FOO//BAR/FOO)")
  end

  def test_colons
    assert_kind_of Net::LDAP::Filter, Net::LDAP::Filter::FilterParser.parse("(ismemberof=cn=edu:berkeley:app:calmessages:deans,ou=campus groups,dc=berkeley,dc=edu)")
  end
end
