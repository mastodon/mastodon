require_relative 'test_helper'

class TestLDAPConnection < Test::Unit::TestCase
  def capture_stderr
    stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = stderr
  end

  # Fake socket for testing
  #
  # FakeTCPSocket.new("success", 636)
  # FakeTCPSocket.new("fail.SocketError", 636)  # raises SocketError
  class FakeTCPSocket
    def initialize(host, port, socket_opts = {})
      status, error = host.split(".")
      raise Object.const_get(error) if status == "fail"
    end
  end

  def test_list_of_hosts_with_first_host_successful
    hosts = [
      ["success.host", 636],
      ["fail.SocketError", 636],
      ["fail.SocketError", 636],
    ]

    connection = Net::LDAP::Connection.new(:hosts => hosts, :socket_class => FakeTCPSocket)
    connection.socket
  end

  def test_list_of_hosts_with_first_host_failure
    hosts = [
      ["fail.SocketError", 636],
      ["success.host", 636],
      ["fail.SocketError", 636],
    ]

    connection = Net::LDAP::Connection.new(:hosts => hosts, :socket_class => FakeTCPSocket)
    connection.socket
  end

  def test_list_of_hosts_with_all_hosts_failure
    hosts = [
      ["fail.SocketError", 636],
      ["fail.SocketError", 636],
      ["fail.SocketError", 636],
    ]

    connection = Net::LDAP::Connection.new(:hosts => hosts, :socket_class => FakeTCPSocket)
    assert_raise Net::LDAP::ConnectionError do
      connection.socket
    end
  end

  # This belongs in test_ldap, not test_ldap_connection
  def test_result_for_connection_failed_is_set
    flexmock(Socket).should_receive(:tcp).and_raise(Errno::ECONNREFUSED)

    ldap_client = Net::LDAP.new(host: '127.0.0.1', port: 12345)

    assert_raise Net::LDAP::ConnectionRefusedError do
      ldap_client.bind(method: :simple, username: 'asdf', password: 'asdf')
    end

    assert_equal(ldap_client.get_operation_result.code, 52)
    assert_equal(ldap_client.get_operation_result.message, 'Unavailable')
  end

  def test_unresponsive_host
    connection = Net::LDAP::Connection.new(:host => "fail.Errno::ETIMEDOUT", :port => 636, :socket_class => FakeTCPSocket)
    assert_raise Net::LDAP::Error do
      connection.socket
    end
  end

  def test_blocked_port
    connection = Net::LDAP::Connection.new(:host => "fail.SocketError", :port => 636, :socket_class => FakeTCPSocket)
    assert_raise Net::LDAP::Error do
      connection.socket
    end
  end

  def test_connection_refused
    connection = Net::LDAP::Connection.new(:host => "fail.Errno::ECONNREFUSED", :port => 636, :socket_class => FakeTCPSocket)
    stderr = capture_stderr do
      assert_raise Net::LDAP::ConnectionRefusedError do
        connection.socket
      end
    end
    assert_equal("Deprecation warning: Net::LDAP::ConnectionRefused will be deprecated. Use Errno::ECONNREFUSED instead.\n",  stderr)
  end

  def test_connection_timeout
    connection = Net::LDAP::Connection.new(:host => "fail.Errno::ETIMEDOUT", :port => 636, :socket_class => FakeTCPSocket)
    stderr = capture_stderr do
      assert_raise Net::LDAP::Error do
        connection.socket
      end
    end
  end

  def test_raises_unknown_exceptions
    connection = Net::LDAP::Connection.new(:host => "fail.StandardError", :port => 636, :socket_class => FakeTCPSocket)
    assert_raise StandardError do
      connection.socket
    end
  end

  def test_modify_ops_delete
    args = { :operations => [[:delete, "mail"]] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = ["0\r\n\x01\x010\b\x04\x04mail1\x00"]
    assert_equal(expected, result)
  end

  def test_modify_ops_add
    args = { :operations => [[:add, "mail", "testuser@example.com"]] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = ["0#\n\x01\x000\x1E\x04\x04mail1\x16\x04\x14testuser@example.com"]
    assert_equal(expected, result)
  end

  def test_modify_ops_replace
    args = { :operations =>[[:replace, "mail", "testuser@example.com"]] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = ["0#\n\x01\x020\x1E\x04\x04mail1\x16\x04\x14testuser@example.com"]
    assert_equal(expected, result)
  end

  def test_write
    mock = flexmock("socket")
    mock.should_receive(:write).with([1.to_ber, "request"].to_ber_sequence).and_return(true)
    conn = Net::LDAP::Connection.new(:socket => mock)
    conn.send(:write, "request")
  end

  def test_write_with_controls
    mock = flexmock("socket")
    mock.should_receive(:write).with([1.to_ber, "request", "controls"].to_ber_sequence).and_return(true)
    conn = Net::LDAP::Connection.new(:socket => mock)
    conn.send(:write, "request", "controls")
  end

  def test_write_increments_msgid
    mock = flexmock("socket")
    mock.should_receive(:write).with([1.to_ber, "request1"].to_ber_sequence).and_return(true)
    mock.should_receive(:write).with([2.to_ber, "request2"].to_ber_sequence).and_return(true)
    conn = Net::LDAP::Connection.new(:socket => mock)
    conn.send(:write, "request1")
    conn.send(:write, "request2")
  end
end

class TestLDAPConnectionSocketReads < Test::Unit::TestCase
  def make_message(message_id, options = {})
    options = {
      app_tag: Net::LDAP::PDU::SearchResult,
      code: Net::LDAP::ResultCodeSuccess,
      matched_dn: "",
      error_message: "",
    }.merge(options)
    result = Net::BER::BerIdentifiedArray.new([options[:code], options[:matched_dn], options[:error_message]])
    result.ber_identifier = options[:app_tag]
    [message_id, result]
  end

  def test_queued_read_drains_queue_before_read
    result1a = make_message(1, error_message: "one")
    result1b = make_message(1, error_message: "two")

    mock = flexmock("socket")
    mock.should_receive(:read_ber).and_return(result1b)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.message_queue[1].push Net::LDAP::PDU.new(result1a)

    assert msg1 = conn.queued_read(1)
    assert msg2 = conn.queued_read(1)

    assert_equal 1, msg1.message_id
    assert_equal "one", msg1.error_message
    assert_equal 1, msg2.message_id
    assert_equal "two", msg2.error_message
  end

  def test_queued_read_reads_until_message_id_match
    result1 = make_message(1)
    result2 = make_message(2)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    conn = Net::LDAP::Connection.new(:socket => mock)

    assert result = conn.queued_read(2)
    assert_equal 2, result.message_id
    assert_equal 1, conn.queued_read(1).message_id
  end

  def test_queued_read_modify
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::ModifyResponse)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    conn.instance_variable_get("@msgid")

    assert result = conn.modify(dn: "uid=modified-user1,ou=People,dc=rubyldap,dc=com",
                                operations: [[:add, :mail, "modified-user1@example.com"]])
    assert result.success?
    assert_equal 2, result.message_id
  end

  def test_queued_read_add
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::AddResponse)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.add(dn: "uid=added-user1,ou=People,dc=rubyldap,dc=com")
    assert result.success?
    assert_equal 2, result.message_id
  end

  def test_queued_read_rename
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::ModifyRDNResponse)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.rename(
      olddn:  "uid=renamable-user1,ou=People,dc=rubyldap,dc=com",
      newrdn: "uid=renamed-user1",
    )
    assert result.success?
    assert_equal 2, result.message_id
  end

  def test_queued_read_delete
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::DeleteResponse)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.delete(dn: "uid=deletable-user1,ou=People,dc=rubyldap,dc=com")
    assert result.success?
    assert_equal 2, result.message_id
  end

  def test_queued_read_setup_encryption_with_start_tls
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::ExtendedResponse)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)
    flexmock(Net::LDAP::Connection).should_receive(:wrap_with_ssl).with(mock, {}, nil).
      and_return(mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.setup_encryption(method: :start_tls)
    assert_equal mock, result
  end

  def test_queued_read_bind_simple
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::BindResult)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.bind(
      method: :simple,
      username: "uid=user1,ou=People,dc=rubyldap,dc=com",
      password: "passworD1")
    assert result.success?
    assert_equal 2, result.message_id
  end

  def test_queued_read_bind_sasl
    result1 = make_message(1, app_tag: Net::LDAP::PDU::SearchResult)
    result2 = make_message(2, app_tag: Net::LDAP::PDU::BindResult)

    mock = flexmock("socket")
    mock.should_receive(:read_ber).
      and_return(result1).
      and_return(result2)
    mock.should_receive(:write)
    conn = Net::LDAP::Connection.new(:socket => mock)

    conn.next_msgid # simulates ongoing query

    assert result = conn.bind(
      method: :sasl,
      mechanism: "fake",
      initial_credential: "passworD1",
      challenge_response: flexmock("challenge proc"))
    assert result.success?
    assert_equal 2, result.message_id
  end
end

class TestLDAPConnectionErrors < Test::Unit::TestCase
  def setup
    @tcp_socket = flexmock(:connection)
    @tcp_socket.should_receive(:write)
    flexmock(Socket).should_receive(:tcp).and_return(@tcp_socket)
    @connection = Net::LDAP::Connection.new(:host => 'test.mocked.com', :port => 636)
  end

  def test_error_failed_operation
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeUnwillingToPerform, "", "The provided password value was rejected by a password validator:  The provided password did not contain enough characters from the character set 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.  The minimum number of characters from that set that must be present in user passwords is 1"])
    ber.ber_identifier = Net::LDAP::PDU::ModifyResponse
    @tcp_socket.should_receive(:read_ber).and_return([1, ber])

    result = @connection.modify(:dn => "1", :operations => [[:replace, "mail", "something@sothsdkf.com"]])
    assert result.failure?, "should be failure"
    assert_equal "The provided password value was rejected by a password validator:  The provided password did not contain enough characters from the character set 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.  The minimum number of characters from that set that must be present in user passwords is 1", result.error_message
  end

  def test_no_error_on_success
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    ber.ber_identifier = Net::LDAP::PDU::ModifyResponse
    @tcp_socket.should_receive(:read_ber).and_return([1, ber])

    result = @connection.modify(:dn => "1", :operations => [[:replace, "mail", "something@sothsdkf.com"]])
    assert result.success?, "should be success"
    assert_equal "", result.error_message
  end
end

class TestLDAPConnectionInstrumentation < Test::Unit::TestCase
  def setup
    @tcp_socket = flexmock(:connection)
    @tcp_socket.should_receive(:write)
    flexmock(Socket).should_receive(:tcp).and_return(@tcp_socket)

    @service = MockInstrumentationService.new
    @connection = Net::LDAP::Connection.new \
      :host => 'test.mocked.com',
      :port => 636,
      :instrumentation_service => @service
  end

  def test_write_net_ldap_connection_event
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    ber.ber_identifier = Net::LDAP::PDU::BindResult
    read_result = [1, ber]
    @tcp_socket.should_receive(:read_ber).and_return(read_result)

    events = @service.subscribe "write.net_ldap_connection"

    result = @connection.bind(method: :anon)
    assert result.success?, "should be success"

    # a write event
    payload, result = events.pop
    assert payload.key?(:result)
    assert payload.key?(:content_length)
  end

  def test_read_net_ldap_connection_event
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    ber.ber_identifier = Net::LDAP::PDU::BindResult
    read_result = [1, ber]
    @tcp_socket.should_receive(:read_ber).and_return(read_result)

    events = @service.subscribe "read.net_ldap_connection"

    result = @connection.bind(method: :anon)
    assert result.success?, "should be success"

    # a read event
    payload, result = events.pop
    assert payload.key?(:result)
    assert_equal read_result, result
  end

  def test_parse_pdu_net_ldap_connection_event
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    ber.ber_identifier = Net::LDAP::PDU::BindResult
    read_result = [1, ber]
    @tcp_socket.should_receive(:read_ber).and_return(read_result)

    events = @service.subscribe "parse_pdu.net_ldap_connection"

    result = @connection.bind(method: :anon)
    assert result.success?, "should be success"

    # a parse_pdu event
    payload, result = events.pop
    assert payload.key?(:pdu)
    assert payload.key?(:app_tag)
    assert payload.key?(:message_id)
    assert_equal Net::LDAP::PDU::BindResult, payload[:app_tag]
    assert_equal 1, payload[:message_id]
    pdu = payload[:pdu]
    assert_equal Net::LDAP::ResultCodeSuccess, pdu.result_code
  end

  def test_bind_net_ldap_connection_event
    ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    ber.ber_identifier = Net::LDAP::PDU::BindResult
    bind_result = [1, ber]
    @tcp_socket.should_receive(:read_ber).and_return(bind_result)

    events = @service.subscribe "bind.net_ldap_connection"

    result = @connection.bind(method: :anon)
    assert result.success?, "should be success"

    # a read event
    payload, result = events.pop
    assert payload.key?(:result)
    assert result.success?, "should be success"
  end

  def test_search_net_ldap_connection_event
    # search data
    search_data_ber = Net::BER::BerIdentifiedArray.new([1, [
      "uid=user1,ou=People,dc=rubyldap,dc=com",
      [["uid", ["user1"]]],
    ]])
    search_data_ber.ber_identifier = Net::LDAP::PDU::SearchReturnedData
    search_data = [1, search_data_ber]
    # search result (end of results)
    search_result_ber = Net::BER::BerIdentifiedArray.new([Net::LDAP::ResultCodeSuccess, "", ""])
    search_result_ber.ber_identifier = Net::LDAP::PDU::SearchResult
    search_result = [1, search_result_ber]
    @tcp_socket.should_receive(:read_ber).and_return(search_data).
                                          and_return(search_result)

    events = @service.subscribe "search.net_ldap_connection"
    unread = @service.subscribe "search_messages_unread.net_ldap_connection"

    result = @connection.search(filter: "(uid=user1)", base: "ou=People,dc=rubyldap,dc=com")
    assert result.success?, "should be success"

    # a search event
    payload, result = events.pop
    assert payload.key?(:result)
    assert payload.key?(:filter)
    assert_equal "(uid=user1)", payload[:filter].to_s
    assert result

    # ensure no unread
    assert unread.empty?, "should not have any leftover unread messages"
  end
end
