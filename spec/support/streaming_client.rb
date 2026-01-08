# frozen_string_literal: true

require 'websocket/driver'

class StreamingClient
  module AUTHENTICATION
    SUBPROTOCOL = 1
    AUTHORIZATION_HEADER = 2
    QUERY_PARAMETER = 3
  end

  class Connection
    attr_reader :url, :messages, :last_error
    attr_accessor :logger, :protocols

    def initialize(url)
      @uri = URI.parse(url)
      @query_params = @uri.query.present? ? URI.decode_www_form(@uri.query).to_h : {}
      @protocols = nil
      @headers = {}

      @dead = false

      @events_queue = Thread::Queue.new
      @messages = []
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
        @events_queue.enq({ event: :message, payload: event.data })
        @messages << event.data
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
      rescue Errno::ECONNRESET
        # Create a synthetic close event:
        close_event = WebSocket::Driver::CloseEvent.new(
          WebSocket::Driver::Hybi::ERRORS[:unexpected_condition],
          'Connection reset'
        )

        finalize(close_event)
      end

      @driver
    end

    def wait_for_event(expected_event, timeout: 10)
      Timeout.timeout(timeout) do
        loop do
          event = dequeue_event

          return nil if event.nil? && @events_queue.closed?
          return event[:payload] unless event.nil? || event[:event] != expected_event
        end
      end
    end

    def write(data)
      @tcp.write(data)
    rescue Errno::EPIPE => e
      logger&.debug("EPIPE: #{e}")
    end

    def finalize(event)
      @dead = true
      @events_queue.enq({ event: :closed, payload: event })
      @events_queue.close
      @thread.kill
    end

    def dequeue_event
      event = @events_queue.pop
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

  def authenticate(access_token, authentication_method = StreamingClient::AUTHENTICATION::SUBPROTOCOL)
    raise 'Invalid access_token passed to StreamingClient, expected a string' unless access_token.is_a?(String)

    case authentication_method
    when AUTHENTICATION::QUERY_PARAMETER
      @connection.set_query_param('access_token', access_token)
    when AUTHENTICATION::SUBPROTOCOL
      @connection.protocols = access_token
    when AUTHENTICATION::AUTHORIZATION_HEADER
      @connection.set_header('Authorization', "Bearer #{access_token}")
    else
      raise 'Invalid authentication method'
    end
  end

  def connect
    @connection.driver.start
    @connection.wait_for_event(:opened)
  end

  def subscribe(channel, **params)
    send(Oj.dump({ type: 'subscribe', stream: channel }.merge(params)))
  end

  def wait_for(event = nil)
    @connection.wait_for_event(event)
  end

  def wait_for_message
    message = @connection.wait_for_event(:message)
    event = Oj.load(message)
    event['payload'] = Oj.load(event['payload']) if event['payload']

    event.deep_symbolize_keys
  end

  delegate :status, :state, to: :'@connection.driver'
  delegate :messages, to: :@connection

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

module StreamingClientHelper
  def streaming_client
    @streaming_client ||= StreamingClient.new
  end
end

RSpec.configure do |config|
  config.include StreamingClientHelper, :streaming
end
