module Lint

  module BlockingCommands

    def setup
      super

      r.rpush("{zap}foo", "s1")
      r.rpush("{zap}foo", "s2")
      r.rpush("{zap}bar", "s1")
      r.rpush("{zap}bar", "s2")
    end

    def to_protocol(obj)
      case obj
      when String
        "$#{obj.length}\r\n#{obj}\r\n"
      when Array
        "*#{obj.length}\r\n" + obj.map { |e| to_protocol(e) }.join
      else
        fail
      end
    end

    def mock(options = {}, &blk)
      commands = {
        :blpop => lambda do |*args|
          sleep options[:delay] if options.has_key?(:delay)
          to_protocol([args.first, args.last])
        end,
        :brpop => lambda do |*args|
          sleep options[:delay] if options.has_key?(:delay)
          to_protocol([args.first, args.last])
        end,
        :brpoplpush => lambda do |*args|
          sleep options[:delay] if options.has_key?(:delay)
          to_protocol(args.last)
        end
      }

      redis_mock(commands, &blk)
    end

    def test_blpop
      assert_equal ["{zap}foo", "s1"], r.blpop("{zap}foo")
      assert_equal ["{zap}foo", "s2"], r.blpop(["{zap}foo"])
      assert_equal ["{zap}bar", "s1"], r.blpop(["{zap}bar", "{zap}foo"])
      assert_equal ["{zap}bar", "s2"], r.blpop(["{zap}foo", "{zap}bar"])
    end

    def test_blpop_timeout
      mock do |r|
        assert_equal ["{zap}foo", "0"], r.blpop("{zap}foo")
        assert_equal ["{zap}foo", "1"], r.blpop("{zap}foo", :timeout => 1)
      end
    end

    def test_blpop_with_old_prototype
      assert_equal ["{zap}foo", "s1"], r.blpop("{zap}foo", 0)
      assert_equal ["{zap}foo", "s2"], r.blpop("{zap}foo", 0)
      assert_equal ["{zap}bar", "s1"], r.blpop("{zap}bar", "{zap}foo", 0)
      assert_equal ["{zap}bar", "s2"], r.blpop("{zap}foo", "{zap}bar", 0)
    end

    def test_blpop_timeout_with_old_prototype
      mock do |r|
        assert_equal ["{zap}foo", "0"], r.blpop("{zap}foo", 0)
        assert_equal ["{zap}foo", "1"], r.blpop("{zap}foo", 1)
      end
    end

    def test_brpop
      assert_equal ["{zap}foo", "s2"], r.brpop("{zap}foo")
      assert_equal ["{zap}foo", "s1"], r.brpop(["{zap}foo"])
      assert_equal ["{zap}bar", "s2"], r.brpop(["{zap}bar", "{zap}foo"])
      assert_equal ["{zap}bar", "s1"], r.brpop(["{zap}foo", "{zap}bar"])
    end

    def test_brpop_timeout
      mock do |r|
        assert_equal ["{zap}foo", "0"], r.brpop("{zap}foo")
        assert_equal ["{zap}foo", "1"], r.brpop("{zap}foo", :timeout => 1)
      end
    end

    def test_brpop_with_old_prototype
      assert_equal ["{zap}foo", "s2"], r.brpop("{zap}foo", 0)
      assert_equal ["{zap}foo", "s1"], r.brpop("{zap}foo", 0)
      assert_equal ["{zap}bar", "s2"], r.brpop("{zap}bar", "{zap}foo", 0)
      assert_equal ["{zap}bar", "s1"], r.brpop("{zap}foo", "{zap}bar", 0)
    end

    def test_brpop_timeout_with_old_prototype
      mock do |r|
        assert_equal ["{zap}foo", "0"], r.brpop("{zap}foo", 0)
        assert_equal ["{zap}foo", "1"], r.brpop("{zap}foo", 1)
      end
    end

    def test_brpoplpush
      assert_equal "s2", r.brpoplpush("{zap}foo", "{zap}qux")
      assert_equal ["s2"], r.lrange("{zap}qux", 0, -1)
    end

    def test_brpoplpush_timeout
      mock do |r|
        assert_equal "0", r.brpoplpush("{zap}foo", "{zap}bar")
        assert_equal "1", r.brpoplpush("{zap}foo", "{zap}bar", :timeout => 1)
      end
    end

    def test_brpoplpush_with_old_prototype
      assert_equal "s2", r.brpoplpush("{zap}foo", "{zap}qux", 0)
      assert_equal ["s2"], r.lrange("{zap}qux", 0, -1)
    end

    def test_brpoplpush_timeout_with_old_prototype
      mock do |r|
        assert_equal "0", r.brpoplpush("{zap}foo", "{zap}bar", 0)
        assert_equal "1", r.brpoplpush("{zap}foo", "{zap}bar", 1)
      end
    end

    driver(:ruby, :hiredis) do
      def test_blpop_socket_timeout
        mock(:delay => 1 + OPTIONS[:timeout] * 2) do |r|
          assert_raises(Redis::TimeoutError) do
            r.blpop("{zap}foo", :timeout => 1)
          end
        end
      end

      def test_brpop_socket_timeout
        mock(:delay => 1 + OPTIONS[:timeout] * 2) do |r|
          assert_raises(Redis::TimeoutError) do
            r.brpop("{zap}foo", :timeout => 1)
          end
        end
      end

      def test_brpoplpush_socket_timeout
        mock(:delay => 1 + OPTIONS[:timeout] * 2) do |r|
          assert_raises(Redis::TimeoutError) do
            r.brpoplpush("{zap}foo", "{zap}bar", :timeout => 1)
          end
        end
      end
    end
  end
end
