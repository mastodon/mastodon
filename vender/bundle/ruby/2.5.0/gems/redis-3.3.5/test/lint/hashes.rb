module Lint

  module Hashes

    def test_hset_and_hget
      r.hset("foo", "f1", "s1")

      assert_equal "s1", r.hget("foo", "f1")
    end

    def test_hsetnx
      r.hset("foo", "f1", "s1")
      r.hsetnx("foo", "f1", "s2")

      assert_equal "s1", r.hget("foo", "f1")

      r.del("foo")
      r.hsetnx("foo", "f1", "s2")

      assert_equal "s2", r.hget("foo", "f1")
    end

    def test_hdel
      r.hset("foo", "f1", "s1")

      assert_equal "s1", r.hget("foo", "f1")

      assert_equal 1, r.hdel("foo", "f1")

      assert_equal nil, r.hget("foo", "f1")
    end

    def test_variadic_hdel
      target_version "2.3.9" do
        r.hset("foo", "f1", "s1")
        r.hset("foo", "f2", "s2")

        assert_equal "s1", r.hget("foo", "f1")
        assert_equal "s2", r.hget("foo", "f2")

        assert_equal 2, r.hdel("foo", ["f1", "f2"])

        assert_equal nil, r.hget("foo", "f1")
        assert_equal nil, r.hget("foo", "f2")
      end
    end

    def test_hexists
      assert_equal false, r.hexists("foo", "f1")

      r.hset("foo", "f1", "s1")

      assert r.hexists("foo", "f1")
    end

    def test_hlen
      assert_equal 0, r.hlen("foo")

      r.hset("foo", "f1", "s1")

      assert_equal 1, r.hlen("foo")

      r.hset("foo", "f2", "s2")

      assert_equal 2, r.hlen("foo")
    end

    def test_hkeys
      assert_equal [], r.hkeys("foo")

      r.hset("foo", "f1", "s1")
      r.hset("foo", "f2", "s2")

      assert_equal ["f1", "f2"], r.hkeys("foo")
    end

    def test_hvals
      assert_equal [], r.hvals("foo")

      r.hset("foo", "f1", "s1")
      r.hset("foo", "f2", "s2")

      assert_equal ["s1", "s2"], r.hvals("foo")
    end

    def test_hgetall
      assert({} == r.hgetall("foo"))

      r.hset("foo", "f1", "s1")
      r.hset("foo", "f2", "s2")

      assert({"f1" => "s1", "f2" => "s2"} == r.hgetall("foo"))
    end

    def test_hmset
      r.hmset("hash", "foo1", "bar1", "foo2", "bar2")

      assert_equal "bar1", r.hget("hash", "foo1")
      assert_equal "bar2", r.hget("hash", "foo2")
    end

    def test_hmset_with_invalid_arguments
      assert_raise(Redis::CommandError) do
        r.hmset("hash", "foo1", "bar1", "foo2", "bar2", "foo3")
      end
    end

    def test_mapped_hmset
      r.mapped_hmset("foo", :f1 => "s1", :f2 => "s2")

      assert_equal "s1", r.hget("foo", "f1")
      assert_equal "s2", r.hget("foo", "f2")
    end

    def test_hmget
      r.hset("foo", "f1", "s1")
      r.hset("foo", "f2", "s2")
      r.hset("foo", "f3", "s3")

      assert_equal ["s2", "s3"], r.hmget("foo", "f2", "f3")
    end

    def test_hmget_mapped
      r.hset("foo", "f1", "s1")
      r.hset("foo", "f2", "s2")
      r.hset("foo", "f3", "s3")

      assert({"f1" => "s1"} == r.mapped_hmget("foo", "f1"))
      assert({"f1" => "s1", "f2" => "s2"} == r.mapped_hmget("foo", "f1", "f2"))
    end

    def test_hincrby
      r.hincrby("foo", "f1", 1)

      assert_equal "1", r.hget("foo", "f1")

      r.hincrby("foo", "f1", 2)

      assert_equal "3", r.hget("foo", "f1")

      r.hincrby("foo", "f1", -1)

      assert_equal "2", r.hget("foo", "f1")
    end

    def test_hincrbyfloat
      target_version "2.5.4" do
        r.hincrbyfloat("foo", "f1", 1.23)

        assert_equal "1.23", r.hget("foo", "f1")

        r.hincrbyfloat("foo", "f1", 0.77)

        assert_equal "2", r.hget("foo", "f1")

        r.hincrbyfloat("foo", "f1", -0.1)

        assert_equal "1.9", r.hget("foo", "f1")
      end
    end
  end
end
