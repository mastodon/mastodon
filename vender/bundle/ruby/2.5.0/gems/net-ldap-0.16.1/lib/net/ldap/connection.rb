# This is a private class used internally by the library. It should not
# be called by user code.
class Net::LDAP::Connection #:nodoc:
  include Net::LDAP::Instrumentation

  # Seconds before failing for socket connect timeout
  DefaultConnectTimeout = 5

  LdapVersion = 3

  # Initialize a connection to an LDAP server
  #
  # :server
  #   :hosts   Array of tuples specifying host, port
  #   :host    host
  #   :port    port
  #   :socket  prepared socket
  #
  def initialize(server = {})
    @server = server
    @instrumentation_service = server[:instrumentation_service]

    # Allows tests to parameterize what socket class to use
    @socket_class = server.fetch(:socket_class, DefaultSocket)

    yield self if block_given?
  end

  def socket_class=(socket_class)
    @socket_class = socket_class
  end

  def prepare_socket(server, timeout=nil)
    socket = server[:socket]
    encryption = server[:encryption]

    @conn = socket
    setup_encryption(encryption, timeout) if encryption
  end

  def open_connection(server)
    hosts = server[:hosts]
    encryption = server[:encryption]

    timeout = server[:connect_timeout] || DefaultConnectTimeout
    socket_opts = {
      connect_timeout: timeout,
    }

    errors = []
    hosts.each do |host, port|
      begin
        prepare_socket(server.merge(socket: @socket_class.new(host, port, socket_opts)), timeout)
        if encryption
          if encryption[:tls_options] &&
             encryption[:tls_options][:verify_mode] &&
             encryption[:tls_options][:verify_mode] == OpenSSL::SSL::VERIFY_NONE
            warn "not verifying SSL hostname of LDAPS server '#{host}:#{port}'"
          else
            @conn.post_connection_check(host)
          end
        end
        return
      rescue Net::LDAP::Error, SocketError, SystemCallError,
             OpenSSL::SSL::SSLError => e
        # Ensure the connection is closed in the event a setup failure.
        close
        errors << [e, host, port]
      end
    end

    raise Net::LDAP::ConnectionError.new(errors)
  end

  module GetbyteForSSLSocket
    def getbyte
      getc.ord
    end
  end

  module FixSSLSocketSyncClose
    def close
      super
      io.close
    end
  end

  def self.wrap_with_ssl(io, tls_options = {}, timeout=nil)
    raise Net::LDAP::NoOpenSSLError, "OpenSSL is unavailable" unless Net::LDAP::HasOpenSSL

    ctx = OpenSSL::SSL::SSLContext.new

    # By default, we do not verify certificates. For a 1.0 release, this should probably be changed at some point.
    # See discussion in https://github.com/ruby-ldap/ruby-net-ldap/pull/161
    ctx.set_params(tls_options) unless tls_options.empty?

    conn = OpenSSL::SSL::SSLSocket.new(io, ctx)

    begin
      if timeout
        conn.connect_nonblock
      else
        conn.connect
      end
    rescue IO::WaitReadable
      raise Errno::ETIMEDOUT, "OpenSSL connection read timeout" unless
        IO.select([conn], nil, nil, timeout)
      retry
    rescue IO::WaitWritable
      raise Errno::ETIMEDOUT, "OpenSSL connection write timeout" unless
        IO.select(nil, [conn], nil, timeout)
      retry
    end

    # Doesn't work:
    # conn.sync_close = true

    conn.extend(GetbyteForSSLSocket) unless conn.respond_to?(:getbyte)
    conn.extend(FixSSLSocketSyncClose)

    conn
  end

  #--
  # Helper method called only from prepare_socket or open_connection, and only
  # after we have a successfully-opened @conn instance variable, which is a TCP
  # connection.  Depending on the received arguments, we establish SSL,
  # potentially replacing the value of @conn accordingly. Don't generate any
  # errors here if no encryption is requested. DO raise Net::LDAP::Error objects
  # if encryption is requested and we have trouble setting it up. That includes
  # if OpenSSL is not set up on the machine. (Question: how does the Ruby
  # OpenSSL wrapper react in that case?) DO NOT filter exceptions raised by the
  # OpenSSL library. Let them pass back to the user. That should make it easier
  # for us to debug the problem reports. Presumably (hopefully?) that will also
  # produce recognizable errors if someone tries to use this on a machine
  # without OpenSSL.
  #
  # The simple_tls method is intended as the simplest, stupidest, easiest
  # solution for people who want nothing more than encrypted comms with the
  # LDAP server. It doesn't do any server-cert validation and requires
  # nothing in the way of key files and root-cert files, etc etc. OBSERVE:
  # WE REPLACE the value of @conn, which is presumed to be a connected
  # TCPSocket object.
  #
  # The start_tls method is supported by many servers over the standard LDAP
  # port. It does not require an alternative port for encrypted
  # communications, as with simple_tls. Thanks for Kouhei Sutou for
  # generously contributing the :start_tls path.
  #++
  def setup_encryption(args, timeout=nil)
    args[:tls_options] ||= {}
    case args[:method]
    when :simple_tls
      @conn = self.class.wrap_with_ssl(@conn, args[:tls_options], timeout)
      # additional branches requiring server validation and peer certs, etc.
      # go here.
    when :start_tls
      message_id = next_msgid
      request    = [
        Net::LDAP::StartTlsOid.to_ber_contextspecific(0),
      ].to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

      write(request, nil, message_id)
      pdu = queued_read(message_id)

      if pdu.nil? || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
        raise Net::LDAP::NoStartTLSResultError, "no start_tls result"
      end

      raise Net::LDAP::StartTLSError,
            "start_tls failed: #{pdu.result_code}" unless pdu.result_code.zero?
      @conn = self.class.wrap_with_ssl(@conn, args[:tls_options], timeout)
    else
      raise Net::LDAP::EncMethodUnsupportedError, "unsupported encryption method #{args[:method]}"
    end
  end

  #--
  # This is provided as a convenience method to make sure a connection
  # object gets closed without waiting for a GC to happen. Clients shouldn't
  # have to call it, but perhaps it will come in handy someday.
  #++
  def close
    return if @conn.nil?
    @conn.close
    @conn = nil
  end

  # Internal: Reads messages by ID from a queue, falling back to reading from
  # the connected socket until a message matching the ID is read. Any messages
  # with mismatched IDs gets queued for subsequent reads by the origin of that
  # message ID.
  #
  # Returns a Net::LDAP::PDU object or nil.
  def queued_read(message_id)
    if pdu = message_queue[message_id].shift
      return pdu
    end

    # read messages until we have a match for the given message_id
    while pdu = read
      return pdu if pdu.message_id == message_id

      message_queue[pdu.message_id].push pdu
      next
    end

    pdu
  end

  # Internal: The internal queue of messages, read from the socket, grouped by
  # message ID.
  #
  # Used by `queued_read` to return messages sent by the server with the given
  # ID. If no messages are queued for that ID, `queued_read` will `read` from
  # the socket and queue messages that don't match the given ID for other
  # readers.
  #
  # Returns the message queue Hash.
  def message_queue
    @message_queue ||= Hash.new do |hash, key|
      hash[key] = []
    end
  end

  # Internal: Reads and parses data from the configured connection.
  #
  # - syntax: the BER syntax to use to parse the read data with
  #
  # Returns parsed Net::LDAP::PDU object.
  def read(syntax = Net::LDAP::AsnSyntax)
    ber_object =
      instrument "read.net_ldap_connection", :syntax => syntax do |payload|
        socket.read_ber(syntax) do |id, content_length|
          payload[:object_type_id] = id
          payload[:content_length] = content_length
        end
      end

    return unless ber_object

    instrument "parse_pdu.net_ldap_connection" do |payload|
      pdu = payload[:pdu]  = Net::LDAP::PDU.new(ber_object)

      payload[:message_id] = pdu.message_id
      payload[:app_tag]    = pdu.app_tag

      pdu
    end
  end
  private :read

  # Internal: Write a BER formatted packet with the next message id to the
  # configured connection.
  #
  # - request: required BER formatted request
  # - controls: optional BER formatted controls
  #
  # Returns the return value from writing to the connection, which in some
  # cases is the Integer number of bytes written to the socket.
  def write(request, controls = nil, message_id = next_msgid)
    instrument "write.net_ldap_connection" do |payload|
      packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
      payload[:content_length] = socket.write(packet)
    end
  end
  private :write

  def next_msgid
    @msgid ||= 0
    @msgid += 1
  end

  def bind(auth)
    instrument "bind.net_ldap_connection" do |payload|
      payload[:method] = meth = auth[:method]
      adapter = Net::LDAP::AuthAdapter[meth]
      adapter.new(self).bind(auth)
    end
  end

  #--
  # Allow the caller to specify a sort control
  #
  # The format of the sort control needs to be:
  #
  # :sort_control => ["cn"]  # just a string
  # or
  # :sort_control => [["cn", "matchingRule", true]] #attribute, matchingRule, direction (true / false)
  # or
  # :sort_control => ["givenname","sn"] #multiple strings or arrays
  #
  def encode_sort_controls(sort_definitions)
    return sort_definitions unless sort_definitions

    sort_control_values = sort_definitions.map do |control|
      control = Array(control) # if there is only an attribute name as a string then infer the orderinrule and reverseorder
      control[0] = String(control[0]).to_ber,
      control[1] = String(control[1]).to_ber,
      control[2] = (control[2] == true).to_ber
      control.to_ber_sequence
    end
    sort_control = [
      Net::LDAP::LDAPControls::SORT_REQUEST.to_ber,
      false.to_ber,
      sort_control_values.to_ber_sequence.to_s.to_ber,
    ].to_ber_sequence
  end

  #--
  # Alternate implementation, this yields each search entry to the caller as
  # it are received.
  #
  # TODO: certain search parameters are hardcoded.
  # TODO: if we mis-parse the server results or the results are wrong, we
  # can block forever. That's because we keep reading results until we get a
  # type-5 packet, which might never come. We need to support the time-limit
  # in the protocol.
  #++
  def search(args = nil)
    args ||= {}

    # filtering, scoping, search base
    # filter: https://tools.ietf.org/html/rfc4511#section-4.5.1.7
    # base:   https://tools.ietf.org/html/rfc4511#section-4.5.1.1
    # scope:  https://tools.ietf.org/html/rfc4511#section-4.5.1.2
    filter = args[:filter] || Net::LDAP::Filter.eq("objectClass", "*")
    base   = args[:base]
    scope  = args[:scope] || Net::LDAP::SearchScope_WholeSubtree

    # attr handling
    # attrs:      https://tools.ietf.org/html/rfc4511#section-4.5.1.8
    # attrs_only: https://tools.ietf.org/html/rfc4511#section-4.5.1.6
    attrs  = Array(args[:attributes])
    attrs_only = args[:attributes_only] == true

    # references
    # refs:  https://tools.ietf.org/html/rfc4511#section-4.5.3
    # deref: https://tools.ietf.org/html/rfc4511#section-4.5.1.3
    refs   = args[:return_referrals] == true
    deref  = args[:deref] || Net::LDAP::DerefAliases_Never

    # limiting, paging, sorting
    # size: https://tools.ietf.org/html/rfc4511#section-4.5.1.4
    # time: https://tools.ietf.org/html/rfc4511#section-4.5.1.5
    size   = args[:size].to_i
    time   = args[:time].to_i
    paged  = args[:paged_searches_supported]
    sort   = args.fetch(:sort_controls, false)

    # arg validation
    raise ArgumentError, "search base is required" unless base
    raise ArgumentError, "invalid search-size" unless size >= 0
    raise ArgumentError, "invalid search scope" unless Net::LDAP::SearchScopes.include?(scope)
    raise ArgumentError, "invalid alias dereferencing value" unless Net::LDAP::DerefAliasesArray.include?(deref)

    # arg transforms
    filter = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)
    ber_attrs = attrs.map { |attr| attr.to_s.to_ber }
    ber_sort  = encode_sort_controls(sort)

    # An interesting value for the size limit would be close to A/D's
    # built-in page limit of 1000 records, but openLDAP newer than version
    # 2.2.0 chokes on anything bigger than 126. You get a silent error that
    # is easily visible by running slapd in debug mode. Go figure.
    #
    # Changed this around 06Sep06 to support a caller-specified search-size
    # limit. Because we ALWAYS do paged searches, we have to work around the
    # problem that it's not legal to specify a "normal" sizelimit (in the
    # body of the search request) that is larger than the page size we're
    # requesting. Unfortunately, I have the feeling that this will break
    # with LDAP servers that don't support paged searches!!!
    #
    # (Because we pass zero as the sizelimit on search rounds when the
    # remaining limit is larger than our max page size of 126. In these
    # cases, I think the caller's search limit will be ignored!)
    #
    # CONFIRMED: This code doesn't work on LDAPs that don't support paged
    # searches when the size limit is larger than 126. We're going to have
    # to do a root-DSE record search and not do a paged search if the LDAP
    # doesn't support it. Yuck.
    rfc2696_cookie = [126, ""]
    result_pdu = nil
    n_results = 0

    message_id = next_msgid

    instrument "search.net_ldap_connection",
               message_id: message_id,
               filter:     filter,
               base:       base,
               scope:      scope,
               size:       size,
               time:       time,
               sort:       sort,
               referrals:  refs,
               deref:      deref,
               attributes: attrs do |payload|
      loop do
        # should collect this into a private helper to clarify the structure
        query_limit = 0
        if size > 0
          query_limit = if paged
                          (((size - n_results) < 126) ? (size - n_results) : 0)
                        else
                          size
                        end
        end

        request = [
          base.to_ber,
          scope.to_ber_enumerated,
          deref.to_ber_enumerated,
          query_limit.to_ber, # size limit
          time.to_ber,
          attrs_only.to_ber,
          filter.to_ber,
          ber_attrs.to_ber_sequence,
        ].to_ber_appsequence(Net::LDAP::PDU::SearchRequest)

        # rfc2696_cookie sometimes contains binary data from Microsoft Active Directory
        # this breaks when calling to_ber. (Can't force binary data to UTF-8)
        # we have to disable paging (even though server supports it) to get around this...

        controls = []
        controls <<
          [
            Net::LDAP::LDAPControls::PAGED_RESULTS.to_ber,
            # Criticality MUST be false to interoperate with normal LDAPs.
            false.to_ber,
            rfc2696_cookie.map(&:to_ber).to_ber_sequence.to_s.to_ber,
          ].to_ber_sequence if paged
        controls << ber_sort if ber_sort
        controls = controls.empty? ? nil : controls.to_ber_contextspecific(0)

        write(request, controls, message_id)

        result_pdu = nil
        controls = []

        while pdu = queued_read(message_id)
          case pdu.app_tag
          when Net::LDAP::PDU::SearchReturnedData
            n_results += 1
            yield pdu.search_entry if block_given?
          when Net::LDAP::PDU::SearchResultReferral
            if refs
              if block_given?
                se = Net::LDAP::Entry.new
                se[:search_referrals] = (pdu.search_referrals || [])
                yield se
              end
            end
          when Net::LDAP::PDU::SearchResult
            result_pdu = pdu
            controls = pdu.result_controls
            if refs && pdu.result_code == Net::LDAP::ResultCodeReferral
              if block_given?
                se = Net::LDAP::Entry.new
                se[:search_referrals] = (pdu.search_referrals || [])
                yield se
              end
            end
            break
          else
            raise Net::LDAP::ResponseTypeInvalidError, "invalid response-type in search: #{pdu.app_tag}"
          end
        end

        # count number of pages of results
        payload[:page_count] ||= 0
        payload[:page_count]  += 1

        # When we get here, we have seen a type-5 response. If there is no
        # error AND there is an RFC-2696 cookie, then query again for the next
        # page of results. If not, we're done. Don't screw this up or we'll
        # break every search we do.
        #
        # Noticed 02Sep06, look at the read_ber call in this loop, shouldn't
        # that have a parameter of AsnSyntax? Does this just accidentally
        # work? According to RFC-2696, the value expected in this position is
        # of type OCTET STRING, covered in the default syntax supported by
        # read_ber, so I guess we're ok.
        more_pages = false
        if result_pdu.result_code == Net::LDAP::ResultCodeSuccess and controls
          controls.each do |c|
            if c.oid == Net::LDAP::LDAPControls::PAGED_RESULTS
              # just in case some bogus server sends us more than 1 of these.
              more_pages = false
              if c.value and c.value.length > 0
                cookie = c.value.read_ber[1]
                if cookie and cookie.length > 0
                  rfc2696_cookie[1] = cookie
                  more_pages = true
                end
              end
            end
          end
        end

        break unless more_pages
      end # loop

      # track total result count
      payload[:result_count] = n_results

      result_pdu || OpenStruct.new(:status => :failure, :result_code => Net::LDAP::ResultCodeOperationsError, :message => "Invalid search")
    end # instrument
  ensure

    # clean up message queue for this search
    messages = message_queue.delete(message_id)

    # in the exceptional case some messages were *not* consumed from the queue,
    # instrument the event but do not fail.
    if !messages.nil? && !messages.empty?
      instrument "search_messages_unread.net_ldap_connection",
                 message_id: message_id, messages: messages
    end
  end

  MODIFY_OPERATIONS = { #:nodoc:
    :add => 0,
    :delete => 1,
    :replace => 2,
  }

  def self.modify_ops(operations)
    ops = []
    if operations
      operations.each do |op, attrib, values|
        # TODO, fix the following line, which gives a bogus error if the
        # opcode is invalid.
        op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated
        values = [values].flatten.map { |v| v.to_ber if v }.to_ber_set
        values = [attrib.to_s.to_ber, values].to_ber_sequence
        ops << [op_ber, values].to_ber
      end
    end
    ops
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  # TODO: We're throwing an exception here on empty DN. Should return a
  # proper error instead, probaby from farther up the chain.
  # TODO: If the user specifies a bogus opcode, we'll throw a confusing
  # error here ("to_ber_enumerated is not defined on nil").
  #++
  def modify(args)
    modify_dn = args[:dn] or raise "Unable to modify empty DN"
    ops = self.class.modify_ops args[:operations]

    message_id = next_msgid
    request    = [
      modify_dn.to_ber,
      ops.to_ber_sequence,
    ].to_ber_appsequence(Net::LDAP::PDU::ModifyRequest)

    write(request, nil, message_id)
    pdu = queued_read(message_id)

    if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyResponse
      raise Net::LDAP::ResponseMissingOrInvalidError, "response missing or invalid"
    end

    pdu
  end

  ##
  # Password Modify
  #
  # http://tools.ietf.org/html/rfc3062
  #
  # passwdModifyOID OBJECT IDENTIFIER ::= 1.3.6.1.4.1.4203.1.11.1
  #
  # PasswdModifyRequestValue ::= SEQUENCE {
  #   userIdentity    [0]  OCTET STRING OPTIONAL
  #   oldPasswd       [1]  OCTET STRING OPTIONAL
  #   newPasswd       [2]  OCTET STRING OPTIONAL }
  #
  # PasswdModifyResponseValue ::= SEQUENCE {
  #   genPasswd       [0]     OCTET STRING OPTIONAL }
  #
  # Encoded request:
  #
  #   00\x02\x01\x02w+\x80\x171.3.6.1.4.1.4203.1.11.1\x81\x100\x0E\x81\x05old\x82\x05new
  #
  def password_modify(args)
    dn = args[:dn]
    raise ArgumentError, 'DN is required' if !dn || dn.empty?

    ext_seq = [Net::LDAP::PasswdModifyOid.to_ber_contextspecific(0)]

    pwd_seq = []
    pwd_seq << dn.to_ber(0x80)
    pwd_seq << args[:old_password].to_ber(0x81) unless args[:old_password].nil?
    pwd_seq << args[:new_password].to_ber(0x82) unless args[:new_password].nil?
    ext_seq << pwd_seq.to_ber_sequence.to_ber(0x81)

    request = ext_seq.to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)

    message_id = next_msgid

    write(request, nil, message_id)
    pdu = queued_read(message_id)

    if !pdu || pdu.app_tag != Net::LDAP::PDU::ExtendedResponse
      raise Net::LDAP::ResponseMissingError, "response missing or invalid"
    end

    pdu
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  # Unlike other operation-methods in this class, we return a result hash
  # rather than a simple result number. This is experimental, and eventually
  # we'll want to do this with all the others. The point is to have access
  # to the error message and the matched-DN returned by the server.
  #++
  def add(args)
    add_dn = args[:dn] or raise Net::LDAP::EmptyDNError, "Unable to add empty DN"
    add_attrs = []
    a = args[:attributes] and a.each do |k, v|
      add_attrs << [k.to_s.to_ber, Array(v).map(&:to_ber).to_ber_set].to_ber_sequence
    end

    message_id = next_msgid
    request    = [add_dn.to_ber, add_attrs.to_ber_sequence].to_ber_appsequence(Net::LDAP::PDU::AddRequest)

    write(request, nil, message_id)
    pdu = queued_read(message_id)

    if !pdu || pdu.app_tag != Net::LDAP::PDU::AddResponse
      raise Net::LDAP::ResponseMissingOrInvalidError, "response missing or invalid"
    end

    pdu
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  #++
  def rename(args)
    old_dn = args[:olddn] or raise "Unable to rename empty DN"
    new_rdn = args[:newrdn] or raise "Unable to rename to empty RDN"
    delete_attrs = args[:delete_attributes] ? true : false
    new_superior = args[:new_superior]

    message_id = next_msgid
    request    = [old_dn.to_ber, new_rdn.to_ber, delete_attrs.to_ber]
    request   << new_superior.to_ber_contextspecific(0) unless new_superior == nil

    write(request.to_ber_appsequence(Net::LDAP::PDU::ModifyRDNRequest), nil, message_id)
    pdu = queued_read(message_id)

    if !pdu || pdu.app_tag != Net::LDAP::PDU::ModifyRDNResponse
      raise Net::LDAP::ResponseMissingOrInvalidError.new "response missing or invalid"
    end

    pdu
  end

  #--
  # TODO, need to support a time limit, in case the server fails to respond.
  #++
  def delete(args)
    dn = args[:dn] or raise "Unable to delete empty DN"
    controls   = args.include?(:control_codes) ? args[:control_codes].to_ber_control : nil #use nil so we can compact later
    message_id = next_msgid
    request    = dn.to_s.to_ber_application_string(Net::LDAP::PDU::DeleteRequest)

    write(request, controls, message_id)
    pdu = queued_read(message_id)

    if !pdu || pdu.app_tag != Net::LDAP::PDU::DeleteResponse
      raise Net::LDAP::ResponseMissingOrInvalidError, "response missing or invalid"
    end

    pdu
  end

  # Internal: Returns a Socket like object used internally to communicate with
  # LDAP server.
  #
  # Typically a TCPSocket, but can be a OpenSSL::SSL::SSLSocket
  def socket
    return @conn if defined? @conn

    # First refactoring uses the existing methods open_connection and
    # prepare_socket to set @conn. Next cleanup would centralize connection
    # handling here.
    if @server[:socket]
      prepare_socket(@server)
    else
      @server[:hosts] = [[@server[:host], @server[:port]]] if @server[:hosts].nil?
      open_connection(@server)
    end

    @conn
  end

  private

  # Wrap around Socket.tcp to normalize with other Socket initializers
  class DefaultSocket
    def self.new(host, port, socket_opts = {})
      Socket.tcp(host, port, socket_opts)
    end
  end
end # class Connection
