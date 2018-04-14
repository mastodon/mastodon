module Lint

  module Lists

    def test_lpush
      r.lpush "foo", "s1"
      r.lpush "foo", "s2"

      assert_equal 2, r.llen("foo")
      assert_equal "s2", r.lpop("foo")
    end

    def test_variadic_lpush
      target_version "2.3.9" do # 2.4-rc6
        assert_equal 3, r.lpush("foo", ["s1", "s2", "s3"])
        assert_equal 3, r.llen("foo")
        assert_equal "s3", r.lpop("foo")
      end
    end

    def test_lpushx
      r.lpushx "foo", "s1"
      r.lpush "foo", "s2"
      r.lpushx "foo", "s3"

      assert_equal 2, r.llen("foo")
      assert_equal ["s3", "s2"], r.lrange("foo", 0, -1)
    end

    def test_rpush
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal 2, r.llen("foo")
      assert_equal "s2", r.rpop("foo")
    end

    def test_variadic_rpush
      target_version "2.3.9" do # 2.4-rc6
        assert_equal 3, r.rpush("foo", ["s1", "s2", "s3"])
        assert_equal 3, r.llen("foo")
        assert_equal "s3", r.rpop("foo")
      end
    end

    def test_rpushx
      r.rpushx "foo", "s1"
      r.rpush "foo", "s2"
      r.rpushx "foo", "s3"

      assert_equal 2, r.llen("foo")
      assert_equal ["s2", "s3"], r.lrange("foo", 0, -1)
    end

    def test_llen
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal 2, r.llen("foo")
    end

    def test_lrange
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"
      r.rpush "foo", "s3"

      assert_equal ["s2", "s3"], r.lrange("foo", 1, -1)
      assert_equal ["s1", "s2"], r.lrange("foo", 0, 1)

      assert_equal [], r.lrange("bar", 0, -1)
    end

    def test_ltrim
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"
      r.rpush "foo", "s3"

      r.ltrim "foo", 0, 1

      assert_equal 2, r.llen("foo")
      assert_equal ["s1", "s2"], r.lrange("foo", 0, -1)
    end

    def test_lindex
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal "s1", r.lindex("foo", 0)
      assert_equal "s2", r.lindex("foo", 1)
    end

    def test_lset
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal "s2", r.lindex("foo", 1)
      assert r.lset("foo", 1, "s3")
      assert_equal "s3", r.lindex("foo", 1)

      assert_raise Redis::CommandError do
        r.lset("foo", 4, "s3")
      end
    end

    def test_lrem
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal 1, r.lrem("foo", 1, "s1")
      assert_equal ["s2"], r.lrange("foo", 0, -1)
    end

    def test_lpop
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal 2, r.llen("foo")
      assert_equal "s1", r.lpop("foo")
      assert_equal 1, r.llen("foo")
    end

    def test_rpop
      r.rpush "foo", "s1"
      r.rpush "foo", "s2"

      assert_equal 2, r.llen("foo")
      assert_equal "s2", r.rpop("foo")
      assert_equal 1, r.llen("foo")
    end

    def test_linsert
      r.rpush "foo", "s1"
      r.rpush "foo", "s3"
      r.linsert "foo", :before, "s3", "s2"

      assert_equal ["s1", "s2", "s3"], r.lrange("foo", 0, -1)

      assert_raise(Redis::CommandError) do
        r.linsert "foo", :anywhere, "s3", "s2"
      end
    end
  end
end
