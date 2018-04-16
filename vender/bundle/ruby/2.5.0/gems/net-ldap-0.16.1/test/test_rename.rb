require_relative 'test_helper'

# Commented out since it assumes you have a live LDAP server somewhere. This
# will be migrated to the integration specs, as soon as they are ready.
=begin
class TestRename < Test::Unit::TestCase
  HOST= '10.10.10.71'
  PORT = 389
  BASE = "o=test"
  AUTH = { :method => :simple, :username => "cn=testadmin,#{BASE}", :password => 'password' }
  BASIC_USER = "cn=jsmith,ou=sales,#{BASE}"
  RENAMED_USER = "cn=jbrown,ou=sales,#{BASE}"
  MOVED_USER = "cn=jsmith,ou=marketing,#{BASE}"
  RENAMED_MOVED_USER = "cn=jjones,ou=marketing,#{BASE}"

  def setup
    # create the entries we're going to manipulate
    Net::LDAP::open(:host => HOST, :port => PORT, :auth => AUTH) do |ldap|
      if ldap.add(:dn => "ou=sales,#{BASE}", :attributes => { :ou => "sales", :objectclass => "organizationalUnit" })
        puts "Add failed: #{ldap.get_operation_result.message} - code: #{ldap.get_operation_result.code}"
      end
      ldap.add(:dn => "ou=marketing,#{BASE}", :attributes => { :ou => "marketing", :objectclass => "organizationalUnit" })
      ldap.add(:dn => BASIC_USER, :attributes => { :cn => "jsmith", :objectclass => "inetOrgPerson", :sn => "Smith" })
    end
  end

  def test_rename_entry
    dn = nil
    Net::LDAP::open(:host => HOST, :port => PORT, :auth => AUTH) do |ldap|
      ldap.rename(:olddn => BASIC_USER, :newrdn => "cn=jbrown")

      ldap.search(:base => RENAMED_USER) do |entry|
        dn = entry.dn
      end
    end
    assert_equal(RENAMED_USER, dn)
  end

  def test_move_entry
    dn = nil
    Net::LDAP::open(:host => HOST, :port => PORT, :auth => AUTH) do |ldap|
      ldap.rename(:olddn => BASIC_USER, :newrdn => "cn=jsmith", :new_superior => "ou=marketing,#{BASE}")

      ldap.search(:base => MOVED_USER) do |entry|
        dn = entry.dn
      end
    end
    assert_equal(MOVED_USER, dn)
  end

  def test_move_and_rename_entry
    dn = nil
    Net::LDAP::open(:host => HOST, :port => PORT, :auth => AUTH) do |ldap|
      ldap.rename(:olddn => BASIC_USER, :newrdn => "cn=jjones", :new_superior => "ou=marketing,#{BASE}")

      ldap.search(:base => RENAMED_MOVED_USER) do |entry|
        dn = entry.dn
      end
    end
    assert_equal(RENAMED_MOVED_USER, dn)
  end

  def teardown
    # delete the entries
    # note: this doesn't always completely clear up on eDirectory as objects get locked while
    # the rename/move is being completed on the server and this prevents the delete from happening
    Net::LDAP::open(:host => HOST, :port => PORT, :auth => AUTH) do |ldap|
      ldap.delete(:dn => BASIC_USER)
      ldap.delete(:dn => RENAMED_USER)
      ldap.delete(:dn => MOVED_USER)
      ldap.delete(:dn => RENAMED_MOVED_USER)
      ldap.delete(:dn => "ou=sales,#{BASE}")
      ldap.delete(:dn => "ou=marketing,#{BASE}")
    end
  end
end
=end
