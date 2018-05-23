require 'test_helper'

class TestLDAPInstrumentation < Test::Unit::TestCase
  # Fake Net::LDAP::Connection for testing
  class FakeConnection
    # It's difficult to instantiate Net::LDAP::PDU objects. Faking out what we
    # need here until that object is brought under test and has it's constructor
    # cleaned up.
    class Result < Struct.new(:success?, :result_code); end

    def initialize
      @bind_success = Result.new(true, Net::LDAP::ResultCodeSuccess)
      @search_success = Result.new(true, Net::LDAP::ResultCodeSizeLimitExceeded)
    end

    def bind(args = {})
      @bind_success
    end

    def search(*args)
      yield @search_success if block_given?
      @search_success
    end
  end

  def setup
    @connection = flexmock(:connection, :close => true)
    flexmock(Net::LDAP::Connection).should_receive(:new).and_return(@connection)

    @service = MockInstrumentationService.new
    @subject = Net::LDAP.new \
      :host => "test.mocked.com", :port => 636,
      :force_no_page => true, # so server capabilities are not queried
      :instrumentation_service => @service
  end

  def test_instrument_bind
    events = @service.subscribe "bind.net_ldap"

    fake_connection = FakeConnection.new
    @subject.connection = fake_connection
    bind_result = fake_connection.bind

    assert @subject.bind

    payload, result = events.pop
    assert result
    assert_equal bind_result, payload[:bind]
  end

  def test_instrument_search
    events = @service.subscribe "search.net_ldap"

    fake_connection = FakeConnection.new
    @subject.connection = fake_connection
    entry = fake_connection.search

    refute_nil @subject.search(:filter => "(uid=user1)")

    payload, result = events.pop
    assert_equal [entry], result
    assert_equal [entry], payload[:result]
    assert_equal "(uid=user1)", payload[:filter]
  end

  def test_instrument_search_with_size
    events = @service.subscribe "search.net_ldap"

    fake_connection = FakeConnection.new
    @subject.connection = fake_connection
    entry = fake_connection.search

    refute_nil @subject.search(:filter => "(uid=user1)", :size => 1)

    payload, result = events.pop
    assert_equal [entry], result
    assert_equal [entry], payload[:result]
    assert_equal "(uid=user1)", payload[:filter]
    assert_equal result.size, payload[:size]
  end

  def test_obscure_auth
    password = "opensesame"
    assert_include(@subject.inspect, "anonymous")
    @subject.auth "joe_user", password
    assert_not_include(@subject.inspect, password)
  end

  def test_encryption
    enc = @subject.encryption('start_tls')

    assert_equal enc[:method], :start_tls
  end

  def test_normalize_encryption_symbol
    enc = @subject.send(:normalize_encryption, :start_tls)
    assert_equal enc, {:method => :start_tls, :tls_options => {}}
  end

  def test_normalize_encryption_nil
    enc = @subject.send(:normalize_encryption, nil)
    assert_equal enc, nil
  end

  def test_normalize_encryption_string
    enc = @subject.send(:normalize_encryption, 'start_tls')
    assert_equal enc, {:method => :start_tls, :tls_options => {}}
  end

  def test_normalize_encryption_hash
    enc = @subject.send(:normalize_encryption, {:method => :start_tls, :tls_options => {:foo => :bar}})
    assert_equal enc, {:method => :start_tls, :tls_options => {:foo => :bar}}
  end
end
