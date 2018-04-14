require_relative 'test_helper'
require 'net/ldap/dn'

class TestDN < Test::Unit::TestCase
  def test_escape
    assert_equal '\\,\\+\\"\\\\\\<\\>\\;', Net::LDAP::DN.escape(',+"\\<>;')
  end

  def test_escape_on_initialize
    dn = Net::LDAP::DN.new('cn', ',+"\\<>;', 'ou=company')
    assert_equal 'cn=\\,\\+\\"\\\\\\<\\>\\;,ou=company', dn.to_s
  end

  def test_to_a
    dn = Net::LDAP::DN.new('cn=James, ou=Company\\,\\20LLC')
    assert_equal ['cn', 'James', 'ou', 'Company, LLC'], dn.to_a
  end

  def test_to_a_parenthesis
    dn = Net::LDAP::DN.new('cn =  \ James , ou  =  "Comp\28ny"  ')
    assert_equal ['cn', ' James', 'ou', 'Comp(ny'], dn.to_a
  end

  def test_to_a_hash_symbol
    dn = Net::LDAP::DN.new('1.23.4=  #A3B4D5  ,ou=Company')
    assert_equal ['1.23.4', '#A3B4D5', 'ou', 'Company'], dn.to_a
  end

  # TODO: raise a more specific exception than RuntimeError
  def test_bad_input_raises_error
    [
      'cn=James,',
      'cn=#aa aa',
      'cn="James',
      'cn=J\ames',
      'cn=\\',
      '1.2.d=Value',
      'd1.2=Value',
    ].each do |input|
      dn = Net::LDAP::DN.new(input)
      assert_raises(RuntimeError) { dn.to_a }
    end
  end
end
