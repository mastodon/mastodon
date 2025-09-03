# frozen_string_literal: true

require 'websocket/driver'

class StreamingClient
  module AUTHENTICATION
    SUBPROTOCOL = 1
    AUTHORIZATION_HEADER = 2
    QUERY_PARAMETER = 3

    def self.supported?(method)
      [
        AUTHENTICATION::SUBPROTOCOL,
        AUTHENTICATION::QUERY_PARAMETER,
        AUTHENTICATION::AUTHORIZATION_HEADER,
      ].include?(method)
    end
  end

  class Connection
    attr_reader :url, :messages, :last_error
    attr_accessor :logger, :protocols

    @logger = nil

    def initialize(url)
      @uri = URI.parse(url)
      @query_params = @uri.query.present? ? URI.decode_www_form(@uri.query).to_h : {}
      @protocols = nil
      @headers = {}

      @dead = false

      @events_queue = Thread::Queue.new
      @messages = Thread::Queue.new
      @last_error = nil
    end

    def set_header(key, value)
      @headers[key] = value
    end

    def set_query_param(key, value)
      @query_params[key] = value
    end

    def driver
      return @driver if defined?(@driver)

      @uri.query = URI.encode_www_form(@query_params)
      @url = @uri.to_s
      @tcp = TCPSocket.new(@uri.host, @uri.port)

      @driver = WebSocket::Driver.client(self, {
        protocols: @protocols,
      })

      @headers.each_pair do |key, value|
        @driver.set_header(key, value)
      end

      at_exit do
        @driver.close
      end

      @driver.on(:open) do
        @events_queue.enq({ event: :opened })
      end

      @driver.on(:message) do |event|
        @events_queue.enq({ event: :message, payload: event })
        @messages << event
      end

      @driver.on(:error) do |event|
        logger&.debug(event.message)
        @events_queue.enq({ event: :error, payload: event })
        @last_error = event
      end

      @driver.on(:close) do |event|
        @events_queue.enq({ event: :closing, payload: event })
        finalize(event)
      end

      @thread = Thread.new do
        @driver.parse(@tcp.read(1)) until @dead || @tcp.closed?
      end

      @driver
    end

    def wait_for_event(expected_event = nil, timeout: 10)
      Timeout.timeout(timeout) do
        loop do
          if expected_event.nil?
            unless (event = dequeue_event(timeout)).nil?
              return event[:payload]
            end
          else
            event = dequeue_event(timeout)

            return nil if event.nil? && @events_queue.closed?
            return event[:payload] unless event.nil? || event[:event] != expected_event
          end
        end
      end
    end

    def write(data)
      @tcp.write(data)
    end

    def finalize(event)
      @dead = true
      @events_queue.enq({ event: :closed, payload: event })
      @events_queue.close
      @thread.kill
    end

    def dequeue_event(timeout)
      event = @events_queue.pop(timeout:)
      logger&.debug(event) unless event.nil?
      event
    end
  end

  def initialize
    @logger = Logger.new($stdout)
    @logger.level = 'info'

    @connection = Connection.new("ws://#{STREAMING_HOST}:#{STREAMING_PORT}/api/v1/streaming")
    @connection.logger = @logger
  end

  def debug!
    @logger.debug!
  end

  def authenticate(access_token, authentication_method)
    raise 'access_token passed to StreamingClient was not a string' unless access_token.is_a?(String)
    raise 'invalid authentication method' unless AUTHENTICATION.supported?(authentication_method)

    case authentication_method
    when AUTHENTICATION::QUERY_PARAMETER
      @connection.set_query_param('access_token', access_token)
    when AUTHENTICATION::SUBPROTOCOL
      @connection.protocols = access_token
    when AUTHENTICATION::AUTHORIZATION_HEADER
      @connection.set_header('Authorization', "Bearer #{access_token}")
    end
  end

  def connect
    @connection.driver.start
    @connection.wait_for_event(:opened)
  end

  def wait_for(event = nil)
    @connection.wait_for_event(event)
  end

  def status_code
    @connection.driver.status
  end

  def state
    @connection.driver.state
  end

  def open?
    state == :open
  end

  def closing?
    state == :closing
  end

  def closed?
    state == :closed
  end

  def send(message)
    @connection.driver.text(message) if open?
  end

  def close
    return if closed?

    @connection.driver.close unless closing?
    @connection.wait_for_event(:closed)
  end
end

RSpec.configure do |config|
  config.around :each, type: :streaming do |example|
    # Streaming server needs DB access but `use_transactional_tests` rolls back
    # every transaction. Disable this feature for streaming tests, and use
    # DatabaseCleaner to clean the database tables between each test.
    self.use_transactional_tests = false

    def streaming_client
      @streaming_client ||= StreamingClient.new
    end

    DatabaseCleaner.cleaning do
      # Load seeds so we have the default roles otherwise cleared by `DatabaseCleaner`
      Rails.application.load_seed

      example.run
    end

    self.use_transactional_tests = true
  end
end
