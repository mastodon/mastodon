module Lint

  module ValueTypes

    def test_exists
      assert_equal false, r.exists("foo")

      r.set("foo", "s1")

      assert_equal true,  r.exists("foo")
    end

    def test_type
      assert_equal "none", r.type("foo")

      r.set("foo", "s1")

      assert_equal "string", r.type("foo")
    end

    def test_keys
      r.set("f", "s1")
      r.set("fo", "s2")
      r.set("foo", "s3")

      assert_equal ["f","fo", "foo"], r.keys("f*").sort
    end

    def test_expire
      r.set("foo", "s1")
      assert r.expire("foo", 2)
      assert_in_range 0..2, r.ttl("foo")
    end

    def test_pexpire
      target_version "2.5.4" do
        r.set("foo", "s1")
        assert r.pexpire("foo", 2000)
        assert_in_range 0..2, r.ttl("foo")
      end
    end

    def test_expireat
      r.set("foo", "s1")
      assert r.expireat("foo", (Time.now + 2).to_i)
      assert_in_range 0..2, r.ttl("foo")
    end

    def test_pexpireat
      target_version "2.5.4" do
        r.set("foo", "s1")
        assert r.pexpireat("foo", (Time.now + 2).to_i * 1_000)
        assert_in_range 0..2, r.ttl("foo")
      end
    end

    def test_persist
      r.set("foo", "s1")
      r.expire("foo", 1)
      r.persist("foo")

      assert(-1 == r.ttl("foo"))
    end

    def test_ttl
      r.set("foo", "s1")
      r.expire("foo", 2)
      assert_in_range 0..2, r.ttl("foo")
    end

    def test_pttl
      target_version "2.5.4" do
        r.set("foo", "s1")
        r.expire("foo", 2)
        assert_in_range 1..2000, r.pttl("foo")
      end
    end

    def test_dump_and_restore
      target_version "2.5.7" do
        r.set("foo", "a")
        v = r.dump("foo")
        r.del("foo")

        assert r.restore("foo", 1000, v)
        assert_equal "a", r.get("foo")
        assert [0, 1].include? r.ttl("foo")

        r.rpush("bar", ["b", "c", "d"])
        w = r.dump("bar")
        r.del("bar")

        assert r.restore("bar", 1000, w)
        assert_equal ["b", "c", "d"], r.lrange("bar", 0, -1)
        assert [0, 1].include? r.ttl("bar")
      end
    end

    def test_move
      r.select 14
      r.flushdb

      r.set "bar", "s3"

      r.select 15

      r.set "foo", "s1"
      r.set "bar", "s2"

      assert r.move("foo", 14)
      assert_equal nil, r.get("foo")

      assert !r.move("bar", 14)
      assert_equal "s2", r.get("bar")

      r.select 14

      assert_equal "s1", r.get("foo")
      assert_equal "s3", r.get("bar")
    end
  end
end
