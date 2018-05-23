require_relative 'test_helper'

class TestEntry < Test::Unit::TestCase
  def setup
    @entry = Net::LDAP::Entry.new 'cn=Barbara,o=corp'
  end

  def test_dn
    assert_equal 'cn=Barbara,o=corp', @entry.dn
  end

  def test_empty_array_when_accessing_nonexistent_attribute
    assert_equal [], @entry['sn']
  end

  def test_attribute_assignment
    @entry['sn'] = 'Jensen'
    assert_equal ['Jensen'], @entry['sn']
    assert_equal ['Jensen'], @entry.sn
    assert_equal ['Jensen'], @entry[:sn]

    @entry[:sn] = 'Jensen'
    assert_equal ['Jensen'], @entry['sn']
    assert_equal ['Jensen'], @entry.sn
    assert_equal ['Jensen'], @entry[:sn]

    @entry.sn = 'Jensen'
    assert_equal ['Jensen'], @entry['sn']
    assert_equal ['Jensen'], @entry.sn
    assert_equal ['Jensen'], @entry[:sn]
  end

  def test_case_insensitive_attribute_names
    @entry['sn'] = 'Jensen'
    assert_equal ['Jensen'], @entry.sn
    assert_equal ['Jensen'], @entry.Sn
    assert_equal ['Jensen'], @entry.SN
    assert_equal ['Jensen'], @entry['sn']
    assert_equal ['Jensen'], @entry['Sn']
    assert_equal ['Jensen'], @entry['SN']
  end
end

class TestEntryLDIF < Test::Unit::TestCase
  def setup
    @entry = Net::LDAP::Entry.from_single_ldif_string(
      %Q{dn: something
foo: foo
barAttribute: bar
      })
  end

  def test_attribute
    assert_equal ['foo'], @entry.foo
    assert_equal ['foo'], @entry.Foo
  end

  def test_modify_attribute
    @entry.foo = 'bar'
    assert_equal ['bar'], @entry.foo

    @entry.fOo= 'baz'
    assert_equal ['baz'], @entry.foo
  end
end
