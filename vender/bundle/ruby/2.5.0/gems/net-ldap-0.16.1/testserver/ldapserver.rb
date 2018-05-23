# $Id$
#
# Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
# Gmail account: garbagecat10.
#
# This is an LDAP server intended for unit testing of Net::LDAP.
# It implements as much of the protocol as we have the stomach
# to implement but serves static data. Use ldapsearch to test
# this server!
#
# To make this easier to write, we use the Ruby/EventMachine
# reactor library.
#

#------------------------------------------------

module LdapServer

  LdapServerAsnSyntax = {
    :application => {
      :constructed => {
        0 => :array,               # LDAP BindRequest
        3 => :array                # LDAP SearchRequest
      },
      :primitive => {
        2 => :string,              # ldapsearch sends this to unbind
      },
    },
    :context_specific => {
      :primitive => {
        0 => :string,              # simple auth (password)
        7 => :string               # present filter
      },
      :constructed => {
        3 => :array                # equality filter
      },
    },
  }

  def post_init
    $logger.info "Accepted LDAP connection"
    @authenticated = false
  end

  def receive_data data
    @data ||= ""; @data << data
    while pdu = @data.read_ber!(LdapServerAsnSyntax)
      begin
      handle_ldap_pdu pdu
      rescue
        $logger.error "closing connection due to error #{$!}"
        close_connection
      end
    end
  end

  def handle_ldap_pdu pdu
    tag_id = pdu[1].ber_identifier
    case tag_id
    when 0x60
      handle_bind_request pdu
    when 0x63
      handle_search_request pdu
    when 0x42
      # bizarre thing, it's a null object (primitive application-2)
      # sent by ldapsearch to request an unbind (or a kiss-off, not sure which)
      close_connection_after_writing
    else
      $logger.error "received unknown packet-type #{tag_id}"
      close_connection_after_writing
    end
  end

  def handle_bind_request pdu
    # TODO, return a proper LDAP error instead of blowing up on version error
    if pdu[1][0] != 3
      send_ldap_response 1, pdu[0].to_i, 2, "", "We only support version 3"
    elsif pdu[1][1] != "cn=bigshot,dc=bayshorenetworks,dc=com"
      send_ldap_response 1, pdu[0].to_i, 48, "", "Who are you?"
    elsif pdu[1][2].ber_identifier != 0x80
      send_ldap_response 1, pdu[0].to_i, 7, "", "Keep it simple, man"
    elsif pdu[1][2] != "opensesame"
      send_ldap_response 1, pdu[0].to_i, 49, "", "Make my day"
    else
      @authenticated = true
      send_ldap_response 1, pdu[0].to_i, 0, pdu[1][1], "I'll take it"
    end
  end



  #--
  # Search Response ::=
  #       CHOICE {
  #            entry          [APPLICATION 4] SEQUENCE {
  #                                objectName     LDAPDN,
  #                                attributes     SEQUENCE OF SEQUENCE {
  #                                                    AttributeType,
  #                                                    SET OF AttributeValue
  #                                               }
  #                           },
  #            resultCode     [APPLICATION 5] LDAPResult
  #        }
  def handle_search_request pdu
    unless @authenticated
      # NOTE, early exit.
      send_ldap_response 5, pdu[0].to_i, 50, "", "Who did you say you were?"
      return
    end

    treebase = pdu[1][0]
    if treebase != "dc=bayshorenetworks,dc=com"
      send_ldap_response 5, pdu[0].to_i, 32, "", "unknown treebase"
      return
    end

    msgid = pdu[0].to_i.to_ber

    # pdu[1][7] is the list of requested attributes.
    # If it's an empty array, that means that *all* attributes were requested.
    requested_attrs = if pdu[1][7].length > 0
      pdu[1][7].map(&:downcase)
    else
      :all
    end

    filters = pdu[1][6]
    if filters.length == 0
      # NOTE, early exit.
      send_ldap_response 5, pdu[0].to_i, 53, "", "No filter specified"
    end

    # TODO, what if this returns nil?
    filter = Net::LDAP::Filter.parse_ldap_filter( filters )

    $ldif.each do |dn, entry|
      if filter.match( entry )
        attrs = []
        entry.each do |k, v|
          if requested_attrs == :all or requested_attrs.include?(k.downcase)
            attrvals = v.map(&:to_ber).to_ber_set
            attrs << [k.to_ber, attrvals].to_ber_sequence
          end
        end

        appseq = [dn.to_ber, attrs.to_ber_sequence].to_ber_appsequence(4)
        pkt = [msgid.to_ber, appseq].to_ber_sequence
        send_data pkt
      end
    end


    send_ldap_response 5, pdu[0].to_i, 0, "", "Was that what you wanted?"
  end



  def send_ldap_response pkt_tag, msgid, code, dn, text
    send_data( [msgid.to_ber, [code.to_ber, dn.to_ber, text.to_ber].to_ber_appsequence(pkt_tag)].to_ber )
  end

end


#------------------------------------------------

# Rather bogus, a global method, which reads a HARDCODED filename
# parses out LDIF data. It will be used to serve LDAP queries out of this server.
#
def load_test_data
  ary = File.readlines( "./testdata.ldif" )
  hash = {}
  while line = ary.shift and line.chomp!
    if line =~ /^dn:[\s]*/i
      dn = $'
      hash[dn] = {}
      while attr = ary.shift and attr.chomp! and attr =~ /^([\w]+)[\s]*:[\s]*/
        hash[dn][$1.downcase] ||= []
        hash[dn][$1.downcase] << $'
      end
    end
  end
  hash
end


#------------------------------------------------

if __FILE__ == $0

  require 'rubygems'
  require 'eventmachine'

  require 'logger'
  $logger = Logger.new $stderr

  $logger.info "adding ../lib to loadpath, to pick up dev version of Net::LDAP."
  $:.unshift "../lib"

  $ldif = load_test_data

  require 'net/ldap'

  EventMachine.run do
    $logger.info "starting LDAP server on 127.0.0.1 port 3890"
    EventMachine.start_server "127.0.0.1", 3890, LdapServer
    EventMachine.add_periodic_timer 60, proc {$logger.info "heartbeat"}
  end
end
