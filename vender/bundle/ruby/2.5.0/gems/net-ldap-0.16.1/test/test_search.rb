# -*- ruby encoding: utf-8 -*-
require_relative 'test_helper'

class TestSearch < Test::Unit::TestCase
  class FakeConnection
    def search(args)
      OpenStruct.new(:result_code => Net::LDAP::ResultCodeOperationsError, :message => "error", :success? => false)
    end
  end

  def setup
    @service = MockInstrumentationService.new
    @connection = Net::LDAP.new :instrumentation_service => @service
    @connection.instance_variable_set(:@open_connection, FakeConnection.new)
  end

  def test_true_result
    assert_nil @connection.search(:return_result => true)
  end

  def test_false_result
    refute @connection.search(:return_result => false)
  end

  def test_no_result
    assert_nil @connection.search
  end

  def test_instrumentation_publishes_event
    events = @service.subscribe "search.net_ldap"

    @connection.search(:filter => "test")

    payload, result = events.pop
    assert payload.key?(:result)
    assert payload.key?(:filter)
    assert_equal "test", payload[:filter]
  end
end
