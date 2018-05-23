# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDistributedScripting < Test::Unit::TestCase

  include Helper::Distributed

  def to_sha(script)
    r.script(:load, script).first
  end

  def test_script_exists
    target_version "2.5.9" do # 2.6-rc1
      a = to_sha("return 1")
      b = a.succ

      assert_equal [true], r.script(:exists, a)
      assert_equal [false], r.script(:exists, b)
      assert_equal [[true]], r.script(:exists, [a])
      assert_equal [[false]], r.script(:exists, [b])
      assert_equal [[true, false]], r.script(:exists, [a, b])
    end
  end

  def test_script_flush
    target_version "2.5.9" do # 2.6-rc1
      sha = to_sha("return 1")
      assert r.script(:exists, sha).first
      assert_equal ["OK"], r.script(:flush)
      assert !r.script(:exists, sha).first
    end
  end

  def test_script_kill
    target_version "2.5.9" do # 2.6-rc1
      redis_mock(:script => lambda { |arg| "+#{arg.upcase}" }) do |redis|
        assert_equal ["KILL"], redis.script(:kill)
      end
    end
  end

  def test_eval
    target_version "2.5.9" do # 2.6-rc1
      assert_raises(Redis::Distributed::CannotDistribute) do
        r.eval("return #KEYS")
      end

      assert_raises(Redis::Distributed::CannotDistribute) do
        r.eval("return KEYS", ["k1", "k2"])
      end

      assert_equal ["k1"], r.eval("return KEYS", ["k1"])
      assert_equal ["a1", "a2"], r.eval("return ARGV", ["k1"], ["a1", "a2"])
    end
  end

  def test_eval_with_options_hash
    target_version "2.5.9" do # 2.6-rc1
      assert_raises(Redis::Distributed::CannotDistribute) do
        r.eval("return #KEYS", {})
      end

      assert_raises(Redis::Distributed::CannotDistribute) do
        r.eval("return KEYS", { :keys => ["k1", "k2"] })
      end

      assert_equal ["k1"], r.eval("return KEYS", { :keys => ["k1"] })
      assert_equal ["a1", "a2"], r.eval("return ARGV", { :keys => ["k1"], :argv => ["a1", "a2"] })
    end
  end

  def test_evalsha
    target_version "2.5.9" do # 2.6-rc1
      assert_raises(Redis::Distributed::CannotDistribute) do
        r.evalsha(to_sha("return #KEYS"))
      end

      assert_raises(Redis::Distributed::CannotDistribute) do
        r.evalsha(to_sha("return KEYS"), ["k1", "k2"])
      end

      assert_equal ["k1"], r.evalsha(to_sha("return KEYS"), ["k1"])
      assert_equal ["a1", "a2"], r.evalsha(to_sha("return ARGV"), ["k1"], ["a1", "a2"])
    end
  end

  def test_evalsha_with_options_hash
    target_version "2.5.9" do # 2.6-rc1
      assert_raises(Redis::Distributed::CannotDistribute) do
        r.evalsha(to_sha("return #KEYS"), {})
      end

      assert_raises(Redis::Distributed::CannotDistribute) do
        r.evalsha(to_sha("return KEYS"), { :keys => ["k1", "k2"] })
      end

      assert_equal ["k1"], r.evalsha(to_sha("return KEYS"), { :keys => ["k1"] })
      assert_equal ["a1", "a2"], r.evalsha(to_sha("return ARGV"), { :keys => ["k1"], :argv => ["a1", "a2"] })
    end
  end
end
