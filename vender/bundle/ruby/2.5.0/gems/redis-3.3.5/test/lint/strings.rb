module Lint

  module Strings

    def test_set_and_get
      r.set("foo", "s1")

      assert_equal "s1", r.get("foo")
    end

    def test_set_and_get_with_brackets
      r["foo"] = "s1"

      assert_equal "s1", r["foo"]
    end

    def test_set_and_get_with_brackets_and_symbol
      r[:foo] = "s1"

      assert_equal "s1", r[:foo]
    end

    def test_set_and_get_with_newline_characters
      r.set("foo", "1\n")

      assert_equal "1\n", r.get("foo")
    end

    def test_set_and_get_with_non_string_value
      value = ["a", "b"]

      r.set("foo", value)

      assert_equal value.to_s, r.get("foo")
    end

    def test_set_and_get_with_ascii_characters
      if defined?(Encoding)
        with_external_encoding("ASCII-8BIT") do
          (0..255).each do |i|
            str = "#{i.chr}---#{i.chr}"
            r.set("foo", str)

            assert_equal str, r.get("foo")
          end
        end
      end
    end

    def test_set_with_ex
      target_version "2.6.12" do
        r.set("foo", "bar", :ex => 2)
        assert_in_range 0..2, r.ttl("foo")
      end
    end

    def test_set_with_px
      target_version "2.6.12" do
        r.set("foo", "bar", :px => 2000)
        assert_in_range 0..2, r.ttl("foo")
      end
    end

    def test_set_with_nx
      target_version "2.6.12" do
        r.set("foo", "qux", :nx => true)
        assert !r.set("foo", "bar", :nx => true)
        assert_equal "qux", r.get("foo")

        r.del("foo")
        assert r.set("foo", "bar", :nx => true)
        assert_equal "bar", r.get("foo")
      end
    end

    def test_set_with_xx
      target_version "2.6.12" do
        r.set("foo", "qux")
        assert r.set("foo", "bar", :xx => true)
        assert_equal "bar", r.get("foo")

        r.del("foo")
        assert !r.set("foo", "bar", :xx => true)
      end
    end

    def test_setex
      assert r.setex("foo", 1, "bar")
      assert_equal "bar", r.get("foo")
      assert [0, 1].include? r.ttl("foo")
    end

    def test_setex_with_non_string_value
      value = ["b", "a", "r"]

      assert r.setex("foo", 1, value)
      assert_equal value.to_s, r.get("foo")
      assert [0, 1].include? r.ttl("foo")
    end

    def test_psetex
      target_version "2.5.4" do
        assert r.psetex("foo", 1000, "bar")
        assert_equal "bar", r.get("foo")
        assert [0, 1].include? r.ttl("foo")
      end
    end

    def test_psetex_with_non_string_value
      target_version "2.5.4" do
        value = ["b", "a", "r"]

        assert r.psetex("foo", 1000, value)
        assert_equal value.to_s, r.get("foo")
        assert [0, 1].include? r.ttl("foo")
      end
    end

    def test_getset
      r.set("foo", "bar")

      assert_equal "bar", r.getset("foo", "baz")
      assert_equal "baz", r.get("foo")
    end

    def test_getset_with_non_string_value
      r.set("foo", "zap")

      value = ["b", "a", "r"]

      assert_equal "zap", r.getset("foo", value)
      assert_equal value.to_s, r.get("foo")
    end

    def test_setnx
      r.set("foo", "qux")
      assert !r.setnx("foo", "bar")
      assert_equal "qux", r.get("foo")

      r.del("foo")
      assert r.setnx("foo", "bar")
      assert_equal "bar", r.get("foo")
    end

    def test_setnx_with_non_string_value
      value = ["b", "a", "r"]

      r.set("foo", "qux")
      assert !r.setnx("foo", value)
      assert_equal "qux", r.get("foo")

      r.del("foo")
      assert r.setnx("foo", value)
      assert_equal value.to_s, r.get("foo")
    end

    def test_incr
      assert_equal 1, r.incr("foo")
      assert_equal 2, r.incr("foo")
      assert_equal 3, r.incr("foo")
    end

    def test_incrby
      assert_equal 1, r.incrby("foo", 1)
      assert_equal 3, r.incrby("foo", 2)
      assert_equal 6, r.incrby("foo", 3)
    end

    def test_incrbyfloat
      target_version "2.5.4" do
        assert_equal 1.23, r.incrbyfloat("foo", 1.23)
        assert_equal 2   , r.incrbyfloat("foo", 0.77)
        assert_equal 1.9 , r.incrbyfloat("foo", -0.1)
      end
    end

    def test_decr
      r.set("foo", 3)

      assert_equal 2, r.decr("foo")
      assert_equal 1, r.decr("foo")
      assert_equal 0, r.decr("foo")
    end

    def test_decrby
      r.set("foo", 6)

      assert_equal 3, r.decrby("foo", 3)
      assert_equal 1, r.decrby("foo", 2)
      assert_equal 0, r.decrby("foo", 1)
    end

    def test_append
      r.set "foo", "s"
      r.append "foo", "1"

      assert_equal "s1", r.get("foo")
    end

    def test_getbit
      r.set("foo", "a")

      assert_equal 1, r.getbit("foo", 1)
      assert_equal 1, r.getbit("foo", 2)
      assert_equal 0, r.getbit("foo", 3)
      assert_equal 0, r.getbit("foo", 4)
      assert_equal 0, r.getbit("foo", 5)
      assert_equal 0, r.getbit("foo", 6)
      assert_equal 1, r.getbit("foo", 7)
    end

    def test_setbit
      r.set("foo", "a")

      r.setbit("foo", 6, 1)

      assert_equal "c", r.get("foo")
    end

    def test_bitcount
      target_version "2.5.10" do
        r.set("foo", "abcde")

        assert_equal 10, r.bitcount("foo", 1, 3)
        assert_equal 17, r.bitcount("foo", 0, -1)
      end
    end

    def test_getrange
      r.set("foo", "abcde")

      assert_equal "bcd", r.getrange("foo", 1, 3)
      assert_equal "abcde", r.getrange("foo", 0, -1)
    end

    def test_setrange
      r.set("foo", "abcde")

      r.setrange("foo", 1, "bar")

      assert_equal "abare", r.get("foo")
    end

    def test_setrange_with_non_string_value
      r.set("foo", "abcde")

      value = ["b", "a", "r"]

      r.setrange("foo", 2, value)

      assert_equal "ab#{value.to_s}", r.get("foo")
    end

    def test_strlen
      r.set "foo", "lorem"

      assert_equal 5, r.strlen("foo")
    end
  end
end
