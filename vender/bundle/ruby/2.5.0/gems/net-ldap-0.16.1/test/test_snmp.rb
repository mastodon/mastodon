# $Id: testsnmp.rb 231 2006-12-21 15:09:29Z blackhedd $

require_relative 'test_helper'
require 'net/snmp'

class TestSnmp < Test::Unit::TestCase
  def self.raw_string(s)
    # Conveniently, String#b only needs to be called when it exists
    s.respond_to?(:b) ? s.b : s
  end

  SnmpGetRequest = raw_string("0'\002\001\000\004\006public\240\032\002\002?*\002\001\000\002\001\0000\0160\f\006\b+\006\001\002\001\001\001\000\005\000")
  SnmpGetResponse = raw_string("0+\002\001\000\004\006public\242\036\002\002'\017\002\001\000\002\001\0000\0220\020\006\b+\006\001\002\001\001\001\000\004\004test")

  SnmpGetRequestXXX = raw_string("0'\002\001\000\004\006xxxxxx\240\032\002\002?*\002\001\000\002\001\0000\0160\f\006\b+\006\001\002\001\001\001\000\005\000")

  def test_invalid_packet
    data = "xxxx"
    assert_raise(Net::BER::BerError) do
ary = data.read_ber(Net::SNMP::AsnSyntax)
    end
  end

  # The method String#read_ber! added by Net::BER consumes a well-formed BER
  # object from the head of a string. If it doesn't find a complete,
  # well-formed BER object, it returns nil and leaves the string unchanged.
  # If it finds an object, it returns the object and removes it from the
  # head of the string. This is good for handling partially-received data
  # streams, such as from network connections.
  def _test_consume_string
    data = "xxx"
    assert_equal(nil, data.read_ber!)
    assert_equal("xxx", data)

    data = SnmpGetRequest + "!!!"
    ary = data.read_ber!(Net::SNMP::AsnSyntax)
    assert_equal("!!!", data)
    assert ary.is_a?(Array)
    assert ary.is_a?(Net::BER::BerIdentifiedArray)
  end

  def test_weird_packet
    assert_raise(Net::SnmpPdu::Error) do
Net::SnmpPdu.parse("aaaaaaaaaaaaaa")
    end
  end

  def test_get_request
    data = SnmpGetRequest.dup
    pkt = data.read_ber(Net::SNMP::AsnSyntax)
    assert pkt.is_a?(Net::BER::BerIdentifiedArray)
    assert_equal(48, pkt.ber_identifier) # Constructed [0], signifies GetRequest

    pdu = Net::SnmpPdu.parse(pkt)
    assert_equal(:get_request, pdu.pdu_type)
    assert_equal(16170, pdu.request_id) # whatever was in the test data. 16170 is not magic.
    assert_equal([[[1, 3, 6, 1, 2, 1, 1, 1, 0], nil]], pdu.variables)

    assert_equal(pdu.to_ber_string, SnmpGetRequest)
  end

  def test_empty_pdu
    pdu = Net::SnmpPdu.new
    assert_raise(Net::SnmpPdu::Error) { pdu.to_ber_string }
  end

  def test_malformations
    pdu = Net::SnmpPdu.new
    pdu.version = 0
    pdu.version = 2
    assert_raise(Net::SnmpPdu::Error) { pdu.version = 100 }

    pdu.pdu_type = :get_request
    pdu.pdu_type = :get_next_request
    pdu.pdu_type = :get_response
    pdu.pdu_type = :set_request
    pdu.pdu_type = :trap
    assert_raise(Net::SnmpPdu::Error) { pdu.pdu_type = :something_else }
  end

  def test_make_response
    pdu = Net::SnmpPdu.new
    pdu.version = 0
    pdu.community = "public"
    pdu.pdu_type = :get_response
    pdu.request_id = 9999
    pdu.error_status = 0
    pdu.error_index = 0
    pdu.add_variable_binding [1, 3, 6, 1, 2, 1, 1, 1, 0], "test"

    assert_equal(SnmpGetResponse, pdu.to_ber_string)
  end

  def test_make_bad_response
    pdu = Net::SnmpPdu.new
    assert_raise(Net::SnmpPdu::Error) {pdu.to_ber_string}
    pdu.pdu_type = :get_response
    pdu.request_id = 999
    pdu.to_ber_string
    # Not specifying variables doesn't create an error. (Maybe it should?)
  end

  def test_snmp_integers
    c32 = Net::SNMP::Counter32.new(100)
    assert_equal("A\001d", c32.to_ber)
    g32 = Net::SNMP::Gauge32.new(100)
    assert_equal("B\001d", g32.to_ber)
    t32 = Net::SNMP::TimeTicks32.new(100)
    assert_equal("C\001d", t32.to_ber)
  end

  def test_community
    data = SnmpGetRequestXXX.dup
    ary = data.read_ber(Net::SNMP::AsnSyntax)
    pdu = Net::SnmpPdu.parse(ary)
    assert_equal("xxxxxx", pdu.community)
  end

end
