require_relative 'test_helper'

class TestFilter < Test::Unit::TestCase
  Filter = Net::LDAP::Filter

  def test_bug_7534_rfc2254
    assert_equal("(cn=Tim Wizard)",
                 Filter.from_rfc2254("(cn=Tim Wizard)").to_rfc2254)
  end

  def test_invalid_filter_string
    assert_raises(Net::LDAP::FilterSyntaxInvalidError) { Filter.from_rfc2254("") }
  end

  def test_invalid_filter
    assert_raises(Net::LDAP::OperatorError) do
      # This test exists to prove that our constructor blocks unknown filter
      # types. All filters must be constructed using helpers.
      Filter.__send__(:new, :xx, nil, nil)
    end
  end

  def test_to_s
    assert_equal("(uid=george *)", Filter.eq("uid", "george *").to_s)
  end

  def test_convenience_filters
    assert_equal("(uid=\\2A)", Filter.equals("uid", "*").to_s)
    assert_equal("(uid=\\28*)", Filter.begins("uid", "(").to_s)
    assert_equal("(uid=*\\29)", Filter.ends("uid", ")").to_s)
    assert_equal("(uid=*\\5C*)", Filter.contains("uid", "\\").to_s)
  end

  def test_c2
    assert_equal("(uid=george *)",
                 Filter.from_rfc2254("uid=george *").to_rfc2254)
    assert_equal("(uid:=george *)",
                 Filter.from_rfc2254("uid:=george *").to_rfc2254)
    assert_equal("(uid=george*)",
                 Filter.from_rfc2254(" ( uid =  george*   ) ").to_rfc2254)
    assert_equal("(!(uid=george*))",
                 Filter.from_rfc2254("uid!=george*").to_rfc2254)
    assert_equal("(uid<=george*)",
                 Filter.from_rfc2254("uid <= george*").to_rfc2254)
    assert_equal("(uid>=george*)",
                 Filter.from_rfc2254("uid>=george*").to_rfc2254)
    assert_equal("(&(uid=george*)(mail=*))",
                 Filter.from_rfc2254("(& (uid=george* ) (mail=*))").to_rfc2254)
    assert_equal("(|(uid=george*)(mail=*))",
                 Filter.from_rfc2254("(| (uid=george* ) (mail=*))").to_rfc2254)
    assert_equal("(!(mail=*))",
                 Filter.from_rfc2254("(! (mail=*))").to_rfc2254)
  end

  def test_filter_with_single_clause
    assert_equal("(cn=name)", Net::LDAP::Filter.construct("(&(cn=name))").to_s)
  end

  def test_filters_from_ber
    [
      Net::LDAP::Filter.eq("objectclass", "*"),
      Net::LDAP::Filter.pres("objectclass"),
      Net::LDAP::Filter.eq("objectclass", "ou"),
      Net::LDAP::Filter.ge("uid", "500"),
      Net::LDAP::Filter.le("uid", "500"),
      (~ Net::LDAP::Filter.pres("objectclass")),
      (Net::LDAP::Filter.pres("objectclass") & Net::LDAP::Filter.pres("ou")),
      (Net::LDAP::Filter.pres("objectclass") & Net::LDAP::Filter.pres("ou") & Net::LDAP::Filter.pres("sn")),
      (Net::LDAP::Filter.pres("objectclass") | Net::LDAP::Filter.pres("ou") | Net::LDAP::Filter.pres("sn")),

      Net::LDAP::Filter.eq("objectclass", "*aaa"),
      Net::LDAP::Filter.eq("objectclass", "*aaa*bbb"),
      Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*ccc"),
      Net::LDAP::Filter.eq("objectclass", "aaa*bbb"),
      Net::LDAP::Filter.eq("objectclass", "aaa*bbb*ccc"),
      Net::LDAP::Filter.eq("objectclass", "abc*def*1111*22*g"),
      Net::LDAP::Filter.eq("objectclass", "*aaa*"),
      Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*"),
      Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*ccc*"),
      Net::LDAP::Filter.eq("objectclass", "aaa*"),
      Net::LDAP::Filter.eq("objectclass", "aaa*bbb*"),
      Net::LDAP::Filter.eq("objectclass", "aaa*bbb*ccc*"),
    ].each do |ber|
      f = Net::LDAP::Filter.parse_ber(ber.to_ber.read_ber(Net::LDAP::AsnSyntax))
      assert(f == ber)
      assert_equal(f.to_ber, ber.to_ber)
    end
  end

  def test_ber_from_rfc2254_filter
    [
      Net::LDAP::Filter.construct("objectclass=*"),
      Net::LDAP::Filter.construct("objectclass=ou"),
      Net::LDAP::Filter.construct("uid >= 500"),
      Net::LDAP::Filter.construct("uid <= 500"),
      Net::LDAP::Filter.construct("(!(uid=*))"),
      Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*))"),
      Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*)(sn=*))"),
      Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*))"),
      Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*)(sn=*))"),

      Net::LDAP::Filter.construct("objectclass=*aaa"),
      Net::LDAP::Filter.construct("objectclass=*aaa*bbb"),
      Net::LDAP::Filter.construct("objectclass=*aaa bbb"),
      Net::LDAP::Filter.construct("objectclass=*aaa  bbb"),
      Net::LDAP::Filter.construct("objectclass=*aaa*bbb*ccc"),
      Net::LDAP::Filter.construct("objectclass=aaa*bbb"),
      Net::LDAP::Filter.construct("objectclass=aaa*bbb*ccc"),
      Net::LDAP::Filter.construct("objectclass=abc*def*1111*22*g"),
      Net::LDAP::Filter.construct("objectclass=*aaa*"),
      Net::LDAP::Filter.construct("objectclass=*aaa*bbb*"),
      Net::LDAP::Filter.construct("objectclass=*aaa*bbb*ccc*"),
      Net::LDAP::Filter.construct("objectclass=aaa*"),
      Net::LDAP::Filter.construct("objectclass=aaa*bbb*"),
      Net::LDAP::Filter.construct("objectclass=aaa*bbb*ccc*"),
    ].each do |ber|
      f = Net::LDAP::Filter.parse_ber(ber.to_ber.read_ber(Net::LDAP::AsnSyntax))
      assert(f == ber)
      assert_equal(f.to_ber, ber.to_ber)
    end
  end
end

# tests ported over from rspec. Not sure if these overlap with the above
# https://github.com/ruby-ldap/ruby-net-ldap/pull/121
class TestFilterRSpec < Test::Unit::TestCase
  def test_ex_convert
    assert_equal '(foo:=bar)', Net::LDAP::Filter.ex('foo', 'bar').to_s
  end

  def test_ex_rfc2254_roundtrip
    filter = Net::LDAP::Filter.ex('foo', 'bar')
    assert_equal filter, Net::LDAP::Filter.from_rfc2254(filter.to_s)
  end

  def test_ber_conversion
    filter = Net::LDAP::Filter.ex('foo', 'bar')
    ber = filter.to_ber
    assert_equal filter, Net::LDAP::Filter.parse_ber(ber.read_ber(Net::LDAP::AsnSyntax))
  end

  [
    '(o:dn:=Ace Industry)',
    '(:dn:2.4.8.10:=Dino)',
    '(cn:dn:1.2.3.4.5:=John Smith)',
    '(sn:dn:2.4.6.8.10:=Barbara Jones)',
    '(&(sn:dn:2.4.6.8.10:=Barbara Jones))',
  ].each_with_index do |filter_str, index|
    define_method "test_decode_filter_#{index}" do
      filter = Net::LDAP::Filter.from_rfc2254(filter_str)
      assert_kind_of Net::LDAP::Filter, filter
    end

    define_method "test_ber_conversion_#{index}" do
      filter = Net::LDAP::Filter.from_rfc2254(filter_str)
      ber = Net::LDAP::Filter.from_rfc2254(filter_str).to_ber
      assert_equal filter, Net::LDAP::Filter.parse_ber(ber.read_ber(Net::LDAP::AsnSyntax))
    end
  end

  def test_apostrophes
    assert_equal "(uid=O'Keefe)", Net::LDAP::Filter.construct("uid=O'Keefe").to_rfc2254
  end

  def test_equals
    assert_equal Net::LDAP::Filter.eq('dn', 'f\2Aoo'), Net::LDAP::Filter.equals('dn', 'f*oo')
  end

  def test_begins
    assert_equal Net::LDAP::Filter.eq('dn', 'f\2Aoo*'), Net::LDAP::Filter.begins('dn', 'f*oo')
  end

  def test_ends
    assert_equal Net::LDAP::Filter.eq('dn', '*f\2Aoo'), Net::LDAP::Filter.ends('dn', 'f*oo')
  end

  def test_contains
    assert_equal Net::LDAP::Filter.eq('dn', '*f\2Aoo*'), Net::LDAP::Filter.contains('dn', 'f*oo')
  end

  def test_escape
    # escapes nul, *, (, ) and \\
    assert_equal "\\00\\2A\\28\\29\\5C", Net::LDAP::Filter.escape("\0*()\\")
  end

  def test_well_known_ber_string
    ber = "\xa4\x2d" \
      "\x04\x0b" "objectclass" \
      "\x30\x1e" \
      "\x80\x08" "foo" "*\\" "bar" \
      "\x81\x08" "foo" "*\\" "bar" \
      "\x82\x08" "foo" "*\\" "bar".b

    [
      "foo" "\\2A\\5C" "bar",
      "foo" "\\2a\\5c" "bar",
      "foo" "\\2A\\5c" "bar",
      "foo" "\\2a\\5C" "bar",
    ].each do |escaped|
      # unescapes escaped characters
      filter = Net::LDAP::Filter.eq("objectclass", "#{escaped}*#{escaped}*#{escaped}")
      assert_equal ber, filter.to_ber
    end
  end

  def test_parse_ber_escapes_characters
    ber = "\xa4\x2d" \
      "\x04\x0b" "objectclass" \
      "\x30\x1e" \
      "\x80\x08" "foo" "*\\" "bar" \
      "\x81\x08" "foo" "*\\" "bar" \
      "\x82\x08" "foo" "*\\" "bar".b

    escaped = Net::LDAP::Filter.escape("foo" "*\\" "bar")
    filter = Net::LDAP::Filter.parse_ber(ber.read_ber(Net::LDAP::AsnSyntax))
    assert_equal "(objectclass=#{escaped}*#{escaped}*#{escaped})", filter.to_s
  end

  def test_unescape_fixnums
    filter = Net::LDAP::Filter.eq("objectclass", 3)
    assert_equal "\xA3\x10\x04\vobjectclass\x04\x013".b, filter.to_ber
  end
end
