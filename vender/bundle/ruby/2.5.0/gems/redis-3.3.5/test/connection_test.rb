require_relative "helper"

class TestConnection < Test::Unit::TestCase

  include Helper::Client

  def test_provides_a_meaningful_inspect
    assert_equal "#<Redis client v#{Redis::VERSION} for redis://127.0.0.1:#{PORT}/15>", r.inspect
  end

  def test_connection_information
    assert_equal "127.0.0.1",                 r.connection.fetch(:host)
    assert_equal 6381,                        r.connection.fetch(:port)
    assert_equal 15,                          r.connection.fetch(:db)
    assert_equal "127.0.0.1:6381",            r.connection.fetch(:location)
    assert_equal "redis://127.0.0.1:6381/15", r.connection.fetch(:id)
  end

  def test_default_id_with_host_and_port
    redis = Redis.new(OPTIONS.merge(:host => "host", :port => "1234", :db => 0))
    assert_equal "redis://host:1234/0", redis.connection.fetch(:id)
  end

  def test_default_id_with_host_and_port_and_explicit_scheme
    redis = Redis.new(OPTIONS.merge(:host => "host", :port => "1234", :db => 0, :scheme => "foo"))
    assert_equal "redis://host:1234/0", redis.connection.fetch(:id)
  end

  def test_default_id_with_path
    redis = Redis.new(OPTIONS.merge(:path => "/tmp/redis.sock", :db => 0))
    assert_equal "redis:///tmp/redis.sock/0", redis.connection.fetch(:id)
  end

  def test_default_id_with_path_and_explicit_scheme
    redis = Redis.new(OPTIONS.merge(:path => "/tmp/redis.sock", :db => 0, :scheme => "foo"))
    assert_equal "redis:///tmp/redis.sock/0", redis.connection.fetch(:id)
  end

  def test_override_id
    redis = Redis.new(OPTIONS.merge(:id => "test"))
    assert_equal "test", redis.connection.fetch(:id)
  end

  def test_id_inside_multi
    redis         = Redis.new(OPTIONS)
    id            = nil
    connection_id = nil

    redis.multi do
      id            = redis.id
      connection_id = redis.connection.fetch(:id)
    end

    assert_equal "redis://127.0.0.1:6381/15", id
    assert_equal "redis://127.0.0.1:6381/15", connection_id
  end
end
