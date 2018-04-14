require File.expand_path("helper", File.dirname(__FILE__))

class TestClient < Test::Unit::TestCase

  include Helper::Client

  def test_call
    result = r.call("PING")
    assert_equal result, "PONG"
  end

  def test_call_with_arguments
    result = r.call("SET", "foo", "bar")
    assert_equal result, "OK"
  end

  def test_call_integers
    result = r.call("INCR", "foo")
    assert_equal result, 1
  end

  def test_call_raise
    assert_raises(Redis::CommandError) do
      r.call("INCR")
    end
  end

  def test_queue_commit
    r.queue("SET", "foo", "bar")
    r.queue("GET", "foo")
    result = r.commit

    assert_equal result, ["OK", "bar"]
  end

  def test_commit_raise
    r.queue("SET", "foo", "bar")
    r.queue("INCR")

    assert_raise(Redis::CommandError) do
      r.commit
    end
  end

  def test_queue_after_error
    r.queue("SET", "foo", "bar")
    r.queue("INCR")

    assert_raise(Redis::CommandError) do
      r.commit
    end

    r.queue("SET",  "foo", "bar")
    r.queue("INCR", "baz")
    result = r.commit

    assert_equal result, ["OK", 1]
  end
end
