# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestInternals < Test::Unit::TestCase

  include Helper::Client
  include Helper::Skipable

  def test_logger
    r.ping

    assert log.string["[Redis] command=PING"]
    assert log.string =~ /\[Redis\] call_time=\d+\.\d+ ms/
  end

  def test_logger_with_pipelining
    r.pipelined do
      r.set "foo", "bar"
      r.get "foo"
    end

    assert log.string[" command=SET args=\"foo\" \"bar\""]
    assert log.string[" command=GET args=\"foo\""]
  end

  def test_recovers_from_failed_commands
    # See https://github.com/redis/redis-rb/issues#issue/28

    assert_raise(Redis::CommandError) do
      r.command_that_doesnt_exist
    end

    assert_nothing_raised do
      r.info
    end
  end

  def test_raises_on_protocol_errors
    redis_mock(:ping => lambda { |*_| "foo" }) do |redis|
      assert_raise(Redis::ProtocolError) do
        redis.ping
      end
    end
  end

  def test_redis_current
    assert_equal "127.0.0.1", Redis.current.client.host
    assert_equal 6379, Redis.current.client.port
    assert_equal 0, Redis.current.client.db

    Redis.current = Redis.new(OPTIONS.merge(:port => 6380, :db => 1))

    t = Thread.new do
      assert_equal "127.0.0.1", Redis.current.client.host
      assert_equal 6380, Redis.current.client.port
      assert_equal 1, Redis.current.client.db
    end

    t.join

    assert_equal "127.0.0.1", Redis.current.client.host
    assert_equal 6380, Redis.current.client.port
    assert_equal 1, Redis.current.client.db
  end

  def test_redis_connected?
    fresh_client = _new_client
    assert !fresh_client.connected?

    fresh_client.ping
    assert fresh_client.connected?

    fresh_client.quit
    assert !fresh_client.connected?
  end

  def test_timeout
    assert_nothing_raised do
      Redis.new(OPTIONS.merge(:timeout => 0))
    end
  end

  driver(:ruby) do
    def test_tcp_keepalive
      keepalive = {:time => 20, :intvl => 10, :probes => 5}

      redis = Redis.new(OPTIONS.merge(:tcp_keepalive => keepalive))
      redis.ping

      connection = redis.client.connection
      actual_keepalive = connection.get_tcp_keepalive

      [:time, :intvl, :probes].each do |key|
        if actual_keepalive.has_key?(key)
          assert_equal actual_keepalive[key], keepalive[key]
        end
      end
    end
  end

  def test_time
    target_version "2.5.4" do
      # Test that the difference between the time that Ruby reports and the time
      # that Redis reports is minimal (prevents the test from being racy).
      rv = r.time

      redis_usec = rv[0] * 1_000_000 + rv[1]
      ruby_usec = Integer(Time.now.to_f * 1_000_000)

      assert 500_000 > (ruby_usec - redis_usec).abs
    end
  end

  def test_connection_timeout
    opts = OPTIONS.merge(:host => "10.255.255.254", :connect_timeout => 0.1, :timeout => 5.0)
    start_time = Time.now
    assert_raise Redis::CannotConnectError do
      Redis.new(opts).ping
    end
    assert (Time.now - start_time) <= opts[:timeout]
  end

  driver(:ruby) do
    def test_write_timeout
      return skip("Relies on buffer sizes, might be unreliable")

      server = TCPServer.new("127.0.0.1", 0)
      port   = server.addr[1]

      # Hacky, but we need the buffer size
      val = TCPSocket.new("127.0.0.1", port).getsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF).unpack("i")[0]

      assert_raise(Redis::TimeoutError) do
        Timeout.timeout(1) do
          redis = Redis.new(:port => port, :timeout => 5, :write_timeout => 0.1)
          redis.set("foo", "1" * val*2)
        end
      end
    end
  end

  def close_on_ping(seq, options = {})
    $request = 0

    command = lambda do
      idx = $request
      $request += 1

      rv = "+%d" % idx
      rv = nil if seq.include?(idx)
      rv
    end

    redis_mock({:ping => command}, {:timeout => 0.1}.merge(options)) do |redis|
      yield(redis)
    end
  end

  def test_retry_by_default
    close_on_ping([0]) do |redis|
      assert_equal "1", redis.ping
    end
  end

  def test_retry_when_wrapped_in_with_reconnect_true
    close_on_ping([0]) do |redis|
      redis.with_reconnect(true) do
        assert_equal "1", redis.ping
      end
    end
  end

  def test_dont_retry_when_wrapped_in_with_reconnect_false
    close_on_ping([0]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.with_reconnect(false) do
          redis.ping
        end
      end
    end
  end

  def test_dont_retry_when_wrapped_in_without_reconnect
    close_on_ping([0]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.without_reconnect do
          redis.ping
        end
      end
    end
  end

  def test_retry_only_once_when_read_raises_econnreset
    close_on_ping([0, 1]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.ping
      end

      assert !redis.client.connected?
    end
  end

  def test_retry_with_custom_reconnect_attempts
    close_on_ping([0, 1], :reconnect_attempts => 2) do |redis|
      assert_equal "2", redis.ping
    end
  end

  def test_retry_with_custom_reconnect_attempts_can_still_fail
    close_on_ping([0, 1, 2], :reconnect_attempts => 2) do |redis|
      assert_raise Redis::ConnectionError do
        redis.ping
      end

      assert !redis.client.connected?
    end
  end

  def test_don_t_retry_when_second_read_in_pipeline_raises_econnreset
    close_on_ping([1]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.pipelined do
          redis.ping
          redis.ping # Second #read times out
        end
      end

      assert !redis.client.connected?
    end
  end

  def close_on_connection(seq)
    $n = 0

    read_command = lambda do |session|
      Array.new(session.gets[1..-3].to_i) do
        bytes = session.gets[1..-3].to_i
        arg = session.read(bytes)
        session.read(2) # Discard \r\n
        arg
      end
    end

    handler = lambda do |session|
      n = $n
      $n += 1

      select = read_command.call(session)
      if select[0].downcase == "select"
        session.write("+OK\r\n")
      else
        raise "Expected SELECT"
      end

      if !seq.include?(n)
        while read_command.call(session)
          session.write("+#{n}\r\n")
        end
      end
    end

    redis_mock_with_handler(handler) do |redis|
      yield(redis)
    end
  end

  def test_retry_on_write_error_by_default
    close_on_connection([0]) do |redis|
      assert_equal "1", redis.client.call(["x" * 128 * 1024])
    end
  end

  def test_retry_on_write_error_when_wrapped_in_with_reconnect_true
    close_on_connection([0]) do |redis|
      redis.with_reconnect(true) do
        assert_equal "1", redis.client.call(["x" * 128 * 1024])
      end
    end
  end

  def test_dont_retry_on_write_error_when_wrapped_in_with_reconnect_false
    close_on_connection([0]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.with_reconnect(false) do
          redis.client.call(["x" * 128 * 1024])
        end
      end
    end
  end

  def test_dont_retry_on_write_error_when_wrapped_in_without_reconnect
    close_on_connection([0]) do |redis|
      assert_raise Redis::ConnectionError do
        redis.without_reconnect do
          redis.client.call(["x" * 128 * 1024])
        end
      end
    end
  end

  def test_connecting_to_unix_domain_socket
    assert_nothing_raised do
      Redis.new(OPTIONS.merge(:path => "./test/db/redis.sock")).ping
    end
  end

  driver(:ruby, :hiredis) do
    def test_bubble_timeout_without_retrying
      serv = TCPServer.new(6380)

      redis = Redis.new(:port => 6380, :timeout => 0.1)

      assert_raise(Redis::TimeoutError) do
        redis.ping
      end

    ensure
      serv.close if serv
    end
  end

  def test_client_options
    redis = Redis.new(OPTIONS.merge(:host => "host", :port => 1234, :db => 1, :scheme => "foo"))

    assert_equal "host", redis.client.options[:host]
    assert_equal 1234, redis.client.options[:port]
    assert_equal 1, redis.client.options[:db]
    assert_equal "foo", redis.client.options[:scheme]
  end

  def test_does_not_change_self_client_options
    redis = Redis.new(OPTIONS.merge(:host => "host", :port => 1234, :db => 1, :scheme => "foo"))
    options = redis.client.options

    options[:host] << "new_host"
    options[:scheme] << "bar"
    options.merge!(:db => 0)

    assert_equal "host", redis.client.options[:host]
    assert_equal 1, redis.client.options[:db]
    assert_equal "foo", redis.client.options[:scheme]
  end

  def test_resolves_localhost
    assert_nothing_raised do
      Redis.new(OPTIONS.merge(:host => 'localhost')).ping
    end
  end

  class << self
    def af_family_supported(af)
      hosts = {
        Socket::AF_INET  => "127.0.0.1",
        Socket::AF_INET6 => "::1",
      }

      begin
        s = Socket.new(af, Socket::SOCK_STREAM, 0)
        begin
          tries = 5
          begin
            sa = Socket.pack_sockaddr_in(1024 + Random.rand(63076), hosts[af])
            s.bind(sa)
          rescue Errno::EADDRINUSE
            tries -= 1
            retry if tries > 0

            raise
          end
          yield
        rescue Errno::EADDRNOTAVAIL
        ensure
          s.close
        end
      rescue Errno::ESOCKTNOSUPPORT
      end
    end
  end

  def af_test(host)
    commands = {
      :ping => lambda { |*_| "+pong" },
    }

    redis_mock(commands, :host => host) do |redis|
      assert_nothing_raised do
        redis.ping
      end
    end
  end

  driver(:ruby) do
    af_family_supported(Socket::AF_INET) do
      def test_connect_ipv4
        af_test("127.0.0.1")
      end
    end
  end

  driver(:ruby) do
    af_family_supported(Socket::AF_INET6) do
      def test_connect_ipv6
        af_test("::1")
      end
    end
  end

  def test_can_be_duped_to_create_a_new_connection
    clients = r.info["connected_clients"].to_i

    r2 = r.dup
    r2.ping

    assert_equal clients + 1, r.info["connected_clients"].to_i
  end
end
