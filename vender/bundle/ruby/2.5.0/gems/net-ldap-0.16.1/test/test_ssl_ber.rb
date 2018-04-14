require_relative 'test_helper'
require 'timeout'

class TestSSLBER < Test::Unit::TestCase
  # Transmits str to @to and reads it back from @from.
  #
  def transmit(str)
    Timeout::timeout(1) do
      @to.write(str)
      @to.close

      @from.read
    end
  end

  def setup
    @from, @to = IO.pipe

    # The production code operates on sockets, which do need #connect called
    # on them to work. Pipes are more robust for this test, so we'll skip
    # the #connect call since it fails.
    #
    # TODO: Replace test with real socket
    # https://github.com/ruby-ldap/ruby-net-ldap/pull/121#discussion_r18746386
    flexmock(OpenSSL::SSL::SSLSocket).
      new_instances.should_receive(:connect => nil)

    @to   = Net::LDAP::Connection.wrap_with_ssl(@to)
    @from = Net::LDAP::Connection.wrap_with_ssl(@from)
  end

  def test_transmit_strings
    assert_equal "foo", transmit("foo")
  end

  def test_transmit_ber_encoded_numbers
    @to.write 1234.to_ber
    assert_equal 1234, @from.read_ber
  end
end
