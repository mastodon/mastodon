module Lint

  module SortedSets

    Infinity = 1.0/0.0

    def test_zadd
      assert_equal 0, r.zcard("foo")
      assert_equal true, r.zadd("foo", 1, "s1")
      assert_equal false, r.zadd("foo", 1, "s1")
      assert_equal 1, r.zcard("foo")
      r.del "foo"

      target_version "3.0.2" do
        # XX option
        assert_equal 0, r.zcard("foo")
        assert_equal false, r.zadd("foo", 1, "s1", :xx => true)
        r.zadd("foo", 1, "s1")
        assert_equal false, r.zadd("foo", 2, "s1", :xx => true)
        assert_equal 2, r.zscore("foo", "s1")
        r.del "foo"

        # NX option
        assert_equal 0, r.zcard("foo")
        assert_equal true, r.zadd("foo", 1, "s1", :nx => true)
        assert_equal false, r.zadd("foo", 2, "s1", :nx => true)
        assert_equal 1, r.zscore("foo", "s1")
        assert_equal 1, r.zcard("foo")
        r.del "foo"

        # CH option
        assert_equal 0, r.zcard("foo")
        assert_equal true, r.zadd("foo", 1, "s1", :ch => true)
        assert_equal false, r.zadd("foo", 1, "s1", :ch => true)
        assert_equal true, r.zadd("foo", 2, "s1", :ch => true)
        assert_equal 1, r.zcard("foo")
        r.del "foo"

        # INCR option
        assert_equal 1.0, r.zadd("foo", 1, "s1", :incr => true)
        assert_equal 11.0, r.zadd("foo", 10, "s1", :incr => true)
        assert_equal(-Infinity, r.zadd("bar", "-inf", "s1", :incr => true))
        assert_equal(+Infinity, r.zadd("bar", "+inf", "s2", :incr => true))
        r.del "foo", "bar"

        # Incompatible options combination
        assert_raise(Redis::CommandError) { r.zadd("foo", 1, "s1", :xx => true, :nx => true) }
      end
    end

    def test_variadic_zadd
      target_version "2.3.9" do # 2.4-rc6
        # Non-nested array with pairs
        assert_equal 0, r.zcard("foo")
        assert_equal 2, r.zadd("foo", [1, "s1", 2, "s2"])
        assert_equal 1, r.zadd("foo", [4, "s1", 5, "s2", 6, "s3"])
        assert_equal 3, r.zcard("foo")
        r.del "foo"

        # Nested array with pairs
        assert_equal 0, r.zcard("foo")
        assert_equal 2, r.zadd("foo", [[1, "s1"], [2, "s2"]])
        assert_equal 1, r.zadd("foo", [[4, "s1"], [5, "s2"], [6, "s3"]])
        assert_equal 3, r.zcard("foo")
        r.del "foo"

        # Wrong number of arguments
        assert_raise(Redis::CommandError) { r.zadd("foo", ["bar"]) }
        assert_raise(Redis::CommandError) { r.zadd("foo", ["bar", "qux", "zap"]) }
      end

      target_version "3.0.2" do
        # XX option
        assert_equal 0, r.zcard("foo")
        assert_equal 0, r.zadd("foo", [1, "s1", 2, "s2"], :xx => true)
        r.zadd("foo", [1, "s1", 2, "s2"])
        assert_equal 0, r.zadd("foo", [2, "s1", 3, "s2", 4, "s3"], :xx => true)
        assert_equal 2, r.zscore("foo", "s1")
        assert_equal 3, r.zscore("foo", "s2")
        assert_equal nil, r.zscore("foo", "s3")
        assert_equal 2, r.zcard("foo")
        r.del "foo"

        # NX option
        assert_equal 0, r.zcard("foo")
        assert_equal 2, r.zadd("foo", [1, "s1", 2, "s2"], :nx => true)
        assert_equal 1, r.zadd("foo", [2, "s1", 3, "s2", 4, "s3"], :nx => true)
        assert_equal 1, r.zscore("foo", "s1")
        assert_equal 2, r.zscore("foo", "s2")
        assert_equal 4, r.zscore("foo", "s3")
        assert_equal 3, r.zcard("foo")
        r.del "foo"

        # CH option
        assert_equal 0, r.zcard("foo")
        assert_equal 2, r.zadd("foo", [1, "s1", 2, "s2"], :ch => true)
        assert_equal 2, r.zadd("foo", [1, "s1", 3, "s2", 4, "s3"], :ch => true)
        assert_equal 3, r.zcard("foo")
        r.del "foo"

        # INCR option
        assert_equal 1.0, r.zadd("foo", [1, "s1"], :incr => true)
        assert_equal 11.0, r.zadd("foo", [10, "s1"], :incr => true)
        assert_equal(-Infinity, r.zadd("bar", ["-inf", "s1"], :incr => true))
        assert_equal(+Infinity, r.zadd("bar", ["+inf", "s2"], :incr => true))
        assert_raise(Redis::CommandError) { r.zadd("foo", [1, "s1", 2, "s2"], :incr => true) }
        r.del "foo", "bar"

        # Incompatible options combination
        assert_raise(Redis::CommandError) { r.zadd("foo", [1, "s1"], :xx => true, :nx => true) }
      end
    end

    def test_zrem
      r.zadd("foo", 1, "s1")
      r.zadd("foo", 2, "s2")

      assert_equal 2, r.zcard("foo")
      assert_equal true, r.zrem("foo", "s1")
      assert_equal false, r.zrem("foo", "s1")
      assert_equal 1, r.zcard("foo")
    end

    def test_variadic_zrem
      target_version "2.3.9" do # 2.4-rc6
        r.zadd("foo", 1, "s1")
        r.zadd("foo", 2, "s2")
        r.zadd("foo", 3, "s3")

        assert_equal 3, r.zcard("foo")
        assert_equal 1, r.zrem("foo", ["s1", "aaa"])
        assert_equal 0, r.zrem("foo", ["bbb", "ccc" "ddd"])
        assert_equal 1, r.zrem("foo", ["eee", "s3"])
        assert_equal 1, r.zcard("foo")
      end
    end

    def test_zincrby
      rv = r.zincrby "foo", 1, "s1"
      assert_equal 1.0, rv

      rv = r.zincrby "foo", 10, "s1"
      assert_equal 11.0, rv

      rv = r.zincrby "bar", "-inf", "s1"
      assert_equal(-Infinity, rv)

      rv = r.zincrby "bar", "+inf", "s2"
      assert_equal(+Infinity, rv)
    end

    def test_zrank
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal 2, r.zrank("foo", "s3")
    end

    def test_zrevrank
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal 0, r.zrevrank("foo", "s3")
    end

    def test_zrange
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal ["s1", "s2"], r.zrange("foo", 0, 1)
      assert_equal [["s1", 1.0], ["s2", 2.0]], r.zrange("foo", 0, 1, :with_scores => true)
      assert_equal [["s1", 1.0], ["s2", 2.0]], r.zrange("foo", 0, 1, :withscores => true)

      r.zadd "bar", "-inf", "s1"
      r.zadd "bar", "+inf", "s2"
      assert_equal [["s1", -Infinity], ["s2", +Infinity]], r.zrange("bar", 0, 1, :with_scores => true)
      assert_equal [["s1", -Infinity], ["s2", +Infinity]], r.zrange("bar", 0, 1, :withscores => true)
    end

    def test_zrevrange
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal ["s3", "s2"], r.zrevrange("foo", 0, 1)
      assert_equal [["s3", 3.0], ["s2", 2.0]], r.zrevrange("foo", 0, 1, :with_scores => true)
      assert_equal [["s3", 3.0], ["s2", 2.0]], r.zrevrange("foo", 0, 1, :withscores => true)

      r.zadd "bar", "-inf", "s1"
      r.zadd "bar", "+inf", "s2"
      assert_equal [["s2", +Infinity], ["s1", -Infinity]], r.zrevrange("bar", 0, 1, :with_scores => true)
      assert_equal [["s2", +Infinity], ["s1", -Infinity]], r.zrevrange("bar", 0, 1, :withscores => true)
    end

    def test_zrangebyscore
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal ["s2", "s3"], r.zrangebyscore("foo", 2, 3)
    end

    def test_zrevrangebyscore
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"

      assert_equal ["s3", "s2"], r.zrevrangebyscore("foo", 3, 2)
    end

    def test_zrangebyscore_with_limit
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"
      r.zadd "foo", 4, "s4"

      assert_equal ["s2"], r.zrangebyscore("foo", 2, 4, :limit => [0, 1])
      assert_equal ["s3"], r.zrangebyscore("foo", 2, 4, :limit => [1, 1])
      assert_equal ["s3", "s4"], r.zrangebyscore("foo", 2, 4, :limit => [1, 2])
    end

    def test_zrevrangebyscore_with_limit
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"
      r.zadd "foo", 4, "s4"

      assert_equal ["s4"], r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1])
      assert_equal ["s3"], r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1])
      assert_equal ["s3", "s2"], r.zrevrangebyscore("foo", 4, 2, :limit => [1, 2])
    end

    def test_zrangebyscore_with_withscores
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"
      r.zadd "foo", 4, "s4"

      assert_equal [["s2", 2.0]], r.zrangebyscore("foo", 2, 4, :limit => [0, 1], :with_scores => true)
      assert_equal [["s3", 3.0]], r.zrangebyscore("foo", 2, 4, :limit => [1, 1], :with_scores => true)
      assert_equal [["s2", 2.0]], r.zrangebyscore("foo", 2, 4, :limit => [0, 1], :withscores => true)
      assert_equal [["s3", 3.0]], r.zrangebyscore("foo", 2, 4, :limit => [1, 1], :withscores => true)

      r.zadd "bar", "-inf", "s1"
      r.zadd "bar", "+inf", "s2"
      assert_equal [["s1", -Infinity]], r.zrangebyscore("bar", -Infinity, +Infinity, :limit => [0, 1], :with_scores => true)
      assert_equal [["s2", +Infinity]], r.zrangebyscore("bar", -Infinity, +Infinity, :limit => [1, 1], :with_scores => true)
      assert_equal [["s1", -Infinity]], r.zrangebyscore("bar", -Infinity, +Infinity, :limit => [0, 1], :withscores => true)
      assert_equal [["s2", +Infinity]], r.zrangebyscore("bar", -Infinity, +Infinity, :limit => [1, 1], :withscores => true)
    end

    def test_zrevrangebyscore_with_withscores
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"
      r.zadd "foo", 4, "s4"

      assert_equal [["s4", 4.0]], r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1], :with_scores => true)
      assert_equal [["s3", 3.0]], r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1], :with_scores => true)
      assert_equal [["s4", 4.0]], r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1], :withscores => true)
      assert_equal [["s3", 3.0]], r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1], :withscores => true)

      r.zadd "bar", "-inf", "s1"
      r.zadd "bar", "+inf", "s2"
      assert_equal [["s2", +Infinity]], r.zrevrangebyscore("bar", +Infinity, -Infinity, :limit => [0, 1], :with_scores => true)
      assert_equal [["s1", -Infinity]], r.zrevrangebyscore("bar", +Infinity, -Infinity, :limit => [1, 1], :with_scores => true)
      assert_equal [["s2", +Infinity]], r.zrevrangebyscore("bar", +Infinity, -Infinity, :limit => [0, 1], :withscores => true)
      assert_equal [["s1", -Infinity]], r.zrevrangebyscore("bar", +Infinity, -Infinity, :limit => [1, 1], :withscores => true)
    end

    def test_zcard
      assert_equal 0, r.zcard("foo")

      r.zadd "foo", 1, "s1"

      assert_equal 1, r.zcard("foo")
    end

    def test_zscore
      r.zadd "foo", 1, "s1"

      assert_equal 1.0, r.zscore("foo", "s1")

      assert_equal nil, r.zscore("foo", "s2")
      assert_equal nil, r.zscore("bar", "s1")

      r.zadd "bar", "-inf", "s1"
      r.zadd "bar", "+inf", "s2"
      assert_equal(-Infinity, r.zscore("bar", "s1"))
      assert_equal(+Infinity, r.zscore("bar", "s2"))
    end

    def test_zremrangebyrank
      r.zadd "foo", 10, "s1"
      r.zadd "foo", 20, "s2"
      r.zadd "foo", 30, "s3"
      r.zadd "foo", 40, "s4"

      assert_equal 3, r.zremrangebyrank("foo", 1, 3)
      assert_equal ["s1"], r.zrange("foo", 0, -1)
    end

    def test_zremrangebyscore
      r.zadd "foo", 1, "s1"
      r.zadd "foo", 2, "s2"
      r.zadd "foo", 3, "s3"
      r.zadd "foo", 4, "s4"

      assert_equal 3, r.zremrangebyscore("foo", 2, 4)
      assert_equal ["s1"], r.zrange("foo", 0, -1)
    end
  end
end
