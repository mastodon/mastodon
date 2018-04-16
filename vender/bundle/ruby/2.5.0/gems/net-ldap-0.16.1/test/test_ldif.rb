# $Id: testldif.rb 61 2006-04-18 20:55:55Z blackhedd $

require_relative 'test_helper'

require 'digest/sha1'
require 'base64'

class TestLdif < Test::Unit::TestCase
  TestLdifFilename = "#{File.dirname(__FILE__)}/testdata.ldif"

  def test_empty_ldif
    ds = Net::LDAP::Dataset.read_ldif(StringIO.new)
    assert_equal(true, ds.empty?)
  end

  def test_ldif_with_version
    io = StringIO.new("version: 1")
    ds = Net::LDAP::Dataset.read_ldif(io)
    assert_equal "1", ds.version
  end

  def test_ldif_with_comments
    str = ["# Hello from LDIF-land", "# This is an unterminated comment"]
    io = StringIO.new(str[0] + "\r\n" + str[1])
    ds = Net::LDAP::Dataset::read_ldif(io)
    assert_equal(str, ds.comments)
  end

  def test_ldif_with_password
    psw = "goldbricks"
    hashed_psw = "{SHA}" + Base64::encode64(Digest::SHA1.digest(psw)).chomp

    ldif_encoded = Base64::encode64(hashed_psw).chomp
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: Goldbrick\r\nuserPassword:: #{ldif_encoded}\r\n\r\n"))
    recovered_psw = ds["Goldbrick"][:userpassword].shift
    assert_equal(hashed_psw, recovered_psw)
  end

  def test_ldif_with_continuation_lines
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: abcdefg\r\n hijklmn\r\n\r\n"))
    assert_equal(true, ds.key?("abcdefghijklmn"))
  end

  def test_ldif_with_continuation_lines_and_extra_whitespace
    ds1 = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: abcdefg\r\n   hijklmn\r\n\r\n"))
    assert_equal(true, ds1.key?("abcdefg  hijklmn"))
    ds2 = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: abcdefg\r\n hij  klmn\r\n\r\n"))
    assert_equal(true, ds2.key?("abcdefghij  klmn"))
  end

  def test_ldif_tab_is_not_continuation
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: key\r\n\tnotcontinued\r\n\r\n"))
    assert_equal(true, ds.key?("key"))
  end

  def test_ldif_with_base64_dn
    str = "dn:: Q049QmFzZTY0IGRuIHRlc3QsT1U9VGVzdCxPVT1Vbml0cyxEQz1leGFtcGxlLERDPWNvbQ==\r\n\r\n"
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new(str))
    assert_equal(true, ds.key?("CN=Base64 dn test,OU=Test,OU=Units,DC=example,DC=com"))
  end

  def test_ldif_with_base64_dn_and_continuation_lines
    str = "dn:: Q049QmFzZTY0IGRuIHRlc3Qgd2l0aCBjb250aW51YXRpb24gbGluZSxPVT1UZXN0LE9VPVVua\r\n XRzLERDPWV4YW1wbGUsREM9Y29t\r\n\r\n"
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new(str))
    assert_equal(true, ds.key?("CN=Base64 dn test with continuation line,OU=Test,OU=Units,DC=example,DC=com"))
  end

  # TODO, INADEQUATE. We need some more tests
  # to verify the content.
  def test_ldif
    File.open(TestLdifFilename, "r") do |f|
      ds = Net::LDAP::Dataset::read_ldif(f)
      assert_equal(13, ds.length)
    end
  end

  # Must test folded lines and base64-encoded lines as well as normal ones.
  def test_to_ldif
    data = File.open(TestLdifFilename, "rb", &:read)
    io = StringIO.new(data)

    # added .lines to turn to array because 1.9 doesn't have
    # .grep on basic strings
    entries = data.lines.grep(/^dn:\s*/) { $'.chomp }
    dn_entries = entries.dup

    ds = Net::LDAP::Dataset::read_ldif(io) do |type, value|
      case type
      when :dn
        assert_equal(dn_entries.first, value)
        dn_entries.shift
      end
    end
    assert_equal(entries.size, ds.size)
    assert_equal(entries.sort, ds.to_ldif.grep(/^dn:\s*/) { $'.chomp })
  end

  def test_to_ldif_with_version
    ds = Net::LDAP::Dataset.new
    ds.version = "1"

    assert_equal "version: 1", ds.to_ldif_string.chomp
  end
end
