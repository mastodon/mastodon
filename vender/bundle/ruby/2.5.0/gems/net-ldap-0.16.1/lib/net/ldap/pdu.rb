# -*- ruby encoding: utf-8 -*-
require 'ostruct'

##
# Defines the Protocol Data Unit (PDU) for LDAP. An LDAP PDU always looks
# like a BER SEQUENCE with at least two elements: an INTEGER message ID
# number and an application-specific SEQUENCE. Some LDAPv3 packets also
# include an optional third element, a sequence of "controls" (see RFC 2251
# section 4.1.12 for more information).
#
# The application-specific tag in the sequence tells us what kind of packet
# it is, and each kind has its own format, defined in RFC-1777.
#
# Observe that many clients (such as ldapsearch) do not necessarily enforce
# the expected application tags on received protocol packets. This
# implementation does interpret the RFC strictly in this regard, and it
# remains to be seen whether there are servers out there that will not work
# well with our approach.
#
# Currently, we only support controls on SearchResult.
#
# http://tools.ietf.org/html/rfc4511#section-4.1.1
# http://tools.ietf.org/html/rfc4511#section-4.1.9
class Net::LDAP::PDU
  class Error < RuntimeError; end

  # http://tools.ietf.org/html/rfc4511#section-4.2
  BindRequest = 0
  # http://tools.ietf.org/html/rfc4511#section-4.2.2
  BindResult = 1
  # http://tools.ietf.org/html/rfc4511#section-4.3
  UnbindRequest = 2
  # http://tools.ietf.org/html/rfc4511#section-4.5.1
  SearchRequest = 3
  # http://tools.ietf.org/html/rfc4511#section-4.5.2
  SearchReturnedData = 4
  SearchResult = 5
  # see also SearchResultReferral (19)
  # http://tools.ietf.org/html/rfc4511#section-4.6
  ModifyRequest  = 6
  ModifyResponse = 7
  # http://tools.ietf.org/html/rfc4511#section-4.7
  AddRequest = 8
  AddResponse = 9
  # http://tools.ietf.org/html/rfc4511#section-4.8
  DeleteRequest = 10
  DeleteResponse = 11
  # http://tools.ietf.org/html/rfc4511#section-4.9
  ModifyRDNRequest  = 12
  ModifyRDNResponse = 13
  # http://tools.ietf.org/html/rfc4511#section-4.10
  CompareRequest = 14
  CompareResponse = 15
  # http://tools.ietf.org/html/rfc4511#section-4.11
  AbandonRequest = 16
  # http://tools.ietf.org/html/rfc4511#section-4.5.2
  SearchResultReferral = 19
  # http://tools.ietf.org/html/rfc4511#section-4.12
  ExtendedRequest = 23
  ExtendedResponse = 24
  # unused: http://tools.ietf.org/html/rfc4511#section-4.13
  IntermediateResponse = 25

  ##
  # The LDAP packet message ID.
  attr_reader :message_id
  alias_method :msg_id, :message_id

  ##
  # The application protocol format tag.
  attr_reader :app_tag

  attr_reader :search_entry
  attr_reader :search_referrals
  attr_reader :search_parameters
  attr_reader :bind_parameters
  attr_reader :extended_response

  ##
  # Returns RFC-2251 Controls if any.
  attr_reader :ldap_controls
  alias_method :result_controls, :ldap_controls
  # Messy. Does this functionality belong somewhere else?

  def initialize(ber_object)
    begin
      @message_id = ber_object[0].to_i
      # Grab the bottom five bits of the identifier so we know which type of
      # PDU this is.
      #
      # This is safe enough in LDAP-land, but it is recommended that other
      # approaches be taken for other protocols in the case that there's an
      # app-specific tag that has both primitive and constructed forms.
      @app_tag = ber_object[1].ber_identifier & 0x1f
      @ldap_controls = []
    rescue Exception => ex
      raise Net::LDAP::PDU::Error, "LDAP PDU Format Error: #{ex.message}"
    end

    case @app_tag
    when BindResult
      parse_bind_response(ber_object[1])
    when SearchReturnedData
      parse_search_return(ber_object[1])
    when SearchResultReferral
      parse_search_referral(ber_object[1])
    when SearchResult
      parse_ldap_result(ber_object[1])
    when ModifyResponse
      parse_ldap_result(ber_object[1])
    when AddResponse
      parse_ldap_result(ber_object[1])
    when DeleteResponse
      parse_ldap_result(ber_object[1])
    when ModifyRDNResponse
      parse_ldap_result(ber_object[1])
    when SearchRequest
      parse_ldap_search_request(ber_object[1])
    when BindRequest
      parse_bind_request(ber_object[1])
    when UnbindRequest
      parse_unbind_request(ber_object[1])
    when ExtendedResponse
      parse_extended_response(ber_object[1])
    else
      raise LdapPduError.new("unknown pdu-type: #{@app_tag}")
    end

    parse_controls(ber_object[2]) if ber_object[2]
  end

  ##
  # Returns a hash which (usually) defines the members :resultCode,
  # :errorMessage, and :matchedDN. These values come directly from an LDAP
  # response packet returned by the remote peer. Also see #result_code.
  def result
    @ldap_result || {}
  end

  def error_message
    result[:errorMessage] || ""
  end

  ##
  # This returns an LDAP result code taken from the PDU, but it will be nil
  # if there wasn't a result code. That can easily happen depending on the
  # type of packet.
  def result_code(code = :resultCode)
    @ldap_result and @ldap_result[code]
  end

  def status
    Net::LDAP::ResultCodesNonError.include?(result_code) ? :success : :failure
  end

  def success?
    status == :success
  end

  def failure?
    !success?
  end

  ##
  # Return serverSaslCreds, which are only present in BindResponse packets.
  #--
  # Messy. Does this functionality belong somewhere else? We ought to
  # refactor the accessors of this class before they get any kludgier.
  def result_server_sasl_creds
    @ldap_result && @ldap_result[:serverSaslCreds]
  end

  def parse_ldap_result(sequence)
    sequence.length >= 3 or raise Net::LDAP::PDU::Error, "Invalid LDAP result length."
    @ldap_result = {
      :resultCode => sequence[0],
      :matchedDN => sequence[1],
      :errorMessage => sequence[2],
    }
    parse_search_referral(sequence[3]) if @ldap_result[:resultCode] == Net::LDAP::ResultCodeReferral
  end
  private :parse_ldap_result

  ##
  # Parse an extended response
  #
  # http://www.ietf.org/rfc/rfc2251.txt
  #
  # Each Extended operation consists of an Extended request and an
  # Extended response.
  #
  #      ExtendedRequest ::= [APPLICATION 23] SEQUENCE {
  #           requestName      [0] LDAPOID,
  #           requestValue     [1] OCTET STRING OPTIONAL }

  def parse_extended_response(sequence)
    sequence.length >= 3 or raise Net::LDAP::PDU::Error, "Invalid LDAP result length."
    @ldap_result = {
      :resultCode => sequence[0],
      :matchedDN => sequence[1],
      :errorMessage => sequence[2],
    }
    @extended_response = sequence[3]
  end
  private :parse_extended_response

  ##
  # A Bind Response may have an additional field, ID [7], serverSaslCreds,
  # per RFC 2251 pgh 4.2.3.
  def parse_bind_response(sequence)
    sequence.length >= 3 or raise Net::LDAP::PDU::Error, "Invalid LDAP Bind Response length."
    parse_ldap_result(sequence)
    @ldap_result[:serverSaslCreds] = sequence[3] if sequence.length >= 4
    @ldap_result
  end
  private :parse_bind_response

  # Definition from RFC 1777 (we're handling application-4 here).
  #
  # Search Response ::=
  #   CHOICE {
  #     entry      [APPLICATION 4] SEQUENCE {
  #                  objectName     LDAPDN,
  #                  attributes     SEQUENCE OF SEQUENCE {
  #                    AttributeType,
  #                    SET OF AttributeValue
  #                  }
  #                },
  #     resultCode [APPLICATION 5] LDAPResult
  #   }
  #
  # We concoct a search response that is a hash of the returned attribute
  # values.
  #
  # NOW OBSERVE CAREFULLY: WE ARE DOWNCASING THE RETURNED ATTRIBUTE NAMES.
  #
  # This is to make them more predictable for user programs, but it may not
  # be a good idea. Maybe this should be configurable.
  def parse_search_return(sequence)
    sequence.length >= 2 or raise Net::LDAP::PDU::Error, "Invalid Search Response length."
    @search_entry = Net::LDAP::Entry.new(sequence[0])
    sequence[1].each { |seq| @search_entry[seq[0]] = seq[1] }
  end
  private :parse_search_return

  ##
  # A search referral is a sequence of one or more LDAP URIs. Any number of
  # search-referral replies can be returned by the server, interspersed with
  # normal replies in any order.
  #--
  # Until I can think of a better way to do this, we'll return the referrals
  # as an array. It'll be up to higher-level handlers to expose something
  # reasonable to the client.
  def parse_search_referral(uris)
    @search_referrals = uris
  end
  private :parse_search_referral

  ##
  # Per RFC 2251, an LDAP "control" is a sequence of tuples, each consisting
  # of an OID, a boolean criticality flag defaulting FALSE, and an OPTIONAL
  # Octet String. If only two fields are given, the second one may be either
  # criticality or data, since criticality has a default value. Someday we
  # may want to come back here and add support for some of more-widely used
  # controls. RFC-2696 is a good example.
  def parse_controls(sequence)
    @ldap_controls = sequence.map do |control|
      o = OpenStruct.new
      o.oid, o.criticality, o.value = control[0], control[1], control[2]
      if o.criticality and o.criticality.is_a?(String)
        o.value = o.criticality
        o.criticality = false
      end
      o
    end
  end
  private :parse_controls

  # (provisional, must document)
  def parse_ldap_search_request(sequence)
    s = OpenStruct.new
    s.base_object, s.scope, s.deref_aliases, s.size_limit, s.time_limit,
      s.types_only, s.filter, s.attributes = sequence
    @search_parameters = s
  end
  private :parse_ldap_search_request

  # (provisional, must document)
  def parse_bind_request sequence
    s = OpenStruct.new
    s.version, s.name, s.authentication = sequence
    @bind_parameters = s
  end
  private :parse_bind_request

  # (provisional, must document)
  # UnbindRequest has no content so this is a no-op.
  def parse_unbind_request(sequence)
    nil
  end
  private :parse_unbind_request
end

module Net
  ##
  # Handle renamed constants Net::LdapPdu (Net::LDAP::PDU) and
  # Net::LdapPduError (Net::LDAP::PDU::Error).
  def self.const_missing(name) #:nodoc:
    case name.to_s
    when "LdapPdu"
      warn "Net::#{name} has been deprecated. Use Net::LDAP::PDU instead."
      Net::LDAP::PDU
    when "LdapPduError"
      warn "Net::#{name} has been deprecated. Use Net::LDAP::PDU::Error instead."
      Net::LDAP::PDU::Error
    when 'LDAP'
    else
      super
    end
  end
end # module Net
