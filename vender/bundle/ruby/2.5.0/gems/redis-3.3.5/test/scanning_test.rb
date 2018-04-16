# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

unless defined?(Enumerator)
  Enumerator = Enumerable::Enumerator
end

class TestScanning < Test::Unit::TestCase

  include Helper::Client

  def test_scan_basic
    target_version "2.7.105" do
      r.debug :populate, 1000

      cursor = 0
      all_keys   = []
      loop {
        cursor, keys = r.scan cursor
        all_keys += keys
        break if cursor == "0"
      }

      assert_equal 1000, all_keys.uniq.size
    end
  end

  def test_scan_count
    target_version "2.7.105" do
      r.debug :populate, 1000

      cursor = 0
      all_keys   = []
      loop {
        cursor, keys = r.scan cursor, :count => 5
        all_keys += keys
        break if cursor == "0"
      }

      assert_equal 1000, all_keys.uniq.size
    end
  end

  def test_scan_match
    target_version "2.7.105" do
      r.debug :populate, 1000

      cursor = 0
      all_keys   = []
      loop {
        cursor, keys = r.scan cursor, :match => "key:1??"
        all_keys += keys
        break if cursor == "0"
      }

      assert_equal 100, all_keys.uniq.size
    end
  end

  def test_scan_each_enumerator
    target_version "2.7.105" do

      r.debug :populate, 1000

      scan_enumerator = r.scan_each
      assert_equal true, scan_enumerator.is_a?(::Enumerator)

      keys_from_scan = scan_enumerator.to_a.uniq
      all_keys = r.keys "*"

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_scan_each_enumerator_match
    target_version "2.7.105" do

      r.debug :populate, 1000

      keys_from_scan = r.scan_each(:match => "key:1??").to_a.uniq
      all_keys = r.keys "key:1??"

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_scan_each_block
    target_version "2.7.105" do

      r.debug :populate, 100

      keys_from_scan   = []
      r.scan_each {|key|
        keys_from_scan << key
      }

      all_keys = r.keys "*"

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_scan_each_block_match
    target_version "2.7.105" do

      r.debug :populate, 100

      keys_from_scan   = []
      r.scan_each(:match => "key:1?") {|key|
        keys_from_scan << key
      }

      all_keys = r.keys "key:1?"

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_sscan_with_encoding
    target_version "2.7.105" do
      [:intset, :hashtable].each do |enc|
        r.del "set"

        prefix = ""
        prefix = "ele:" if enc == :hashtable

        elements = []
        100.times { |j| elements << "#{prefix}#{j}" }

        r.sadd "set", elements

        assert_equal enc.to_s, r.object("encoding", "set")

        cursor = 0
        all_keys   = []
        loop {
          cursor, keys = r.sscan "set", cursor
          all_keys += keys
          break if cursor == "0"
        }

        assert_equal 100, all_keys.uniq.size
      end
    end
  end

  def test_sscan_each_enumerator
    target_version "2.7.105" do
      elements = []
      100.times { |j| elements << "ele:#{j}" }
      r.sadd "set", elements

      scan_enumerator = r.sscan_each("set")
      assert_equal true, scan_enumerator.is_a?(::Enumerator)

      keys_from_scan = scan_enumerator.to_a.uniq
      all_keys = r.smembers("set")

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_sscan_each_enumerator_match
    target_version "2.7.105" do
      elements = []
      100.times { |j| elements << "ele:#{j}" }
      r.sadd "set", elements

      keys_from_scan = r.sscan_each("set", :match => "ele:1?").to_a.uniq

      all_keys = r.smembers("set").grep(/^ele:1.$/)

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_sscan_each_enumerator_block
    target_version "2.7.105" do
      elements = []
      100.times { |j| elements << "ele:#{j}" }
      r.sadd "set", elements

      keys_from_scan = []
      r.sscan_each("set") do |key|
        keys_from_scan << key
      end

      all_keys = r.smembers("set")

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_sscan_each_enumerator_block_match
    target_version "2.7.105" do
      elements = []
      100.times { |j| elements << "ele:#{j}" }
      r.sadd "set", elements

      keys_from_scan = []
      r.sscan_each("set", :match => "ele:1?") do |key|
        keys_from_scan << key
      end

      all_keys = r.smembers("set").grep(/^ele:1.$/)

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_hscan_with_encoding
    target_version "2.7.105" do
      [:ziplist, :hashtable].each do |enc|
        r.del "set"

        count = 1000
        count = 30 if enc == :ziplist

        elements = []
        count.times { |j| elements << "key:#{j}" << j.to_s }

        r.hmset "hash", *elements

        assert_equal enc.to_s, r.object("encoding", "hash")

        cursor = 0
        all_key_values   = []
        loop {
          cursor, key_values = r.hscan "hash", cursor
          all_key_values.concat key_values
          break if cursor == "0"
        }

        keys2 = []
        all_key_values.each do |k, v|
          assert_equal "key:#{v}", k
          keys2 << k
        end

        assert_equal count, keys2.uniq.size
      end
    end
  end

  def test_hscan_each_enumerator
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << "key:#{j}" << j.to_s }
      r.hmset "hash", *elements

      scan_enumerator = r.hscan_each("hash")
      assert_equal true, scan_enumerator.is_a?(::Enumerator)

      keys_from_scan = scan_enumerator.to_a.uniq
      all_keys = r.hgetall("hash").to_a

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_hscan_each_enumerator_match
    target_version "2.7.105" do
      count = 100
      elements = []
      count.times { |j| elements << "key:#{j}" << j.to_s }
      r.hmset "hash", *elements

      keys_from_scan = r.hscan_each("hash", :match => "key:1?").to_a.uniq
      all_keys = r.hgetall("hash").to_a.select{|k,v| k =~ /^key:1.$/}

      assert all_keys.sort == keys_from_scan.sort
    end
  end

  def test_hscan_each_block
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << "key:#{j}" << j.to_s }
      r.hmset "hash", *elements

      keys_from_scan = []
      r.hscan_each("hash") do |field, value|
        keys_from_scan << [field, value]
      end
      all_keys = r.hgetall("hash").to_a

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_hscan_each_block_match
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << "key:#{j}" << j.to_s }
      r.hmset "hash", *elements

      keys_from_scan = []
      r.hscan_each("hash", :match => "key:1?") do |field, value|
        keys_from_scan << [field, value]
      end
      all_keys = r.hgetall("hash").to_a.select{|k,v| k =~ /^key:1.$/}

      assert all_keys.sort == keys_from_scan.uniq.sort
    end
  end

  def test_zscan_with_encoding
    target_version "2.7.105" do
      [:ziplist, :skiplist].each do |enc|
        r.del "zset"

        count = 1000
        count = 30 if enc == :ziplist

        elements = []
        count.times { |j| elements << j << "key:#{j}" }

        r.zadd "zset", elements

        assert_equal enc.to_s, r.object("encoding", "zset")

        cursor = 0
        all_key_scores   = []
        loop {
          cursor, key_scores = r.zscan "zset", cursor
          all_key_scores.concat  key_scores
          break if cursor == "0"
        }

        keys2 = []
        all_key_scores.each do |k, v|
          assert_equal true, v.is_a?(Float)
          assert_equal "key:#{Integer(v)}", k
          keys2 << k
        end

        assert_equal count, keys2.uniq.size
      end
    end
  end

  def test_zscan_each_enumerator
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << j << "key:#{j}" }
      r.zadd "zset", elements

      scan_enumerator = r.zscan_each "zset"
      assert_equal true, scan_enumerator.is_a?(::Enumerator)

      scores_from_scan = scan_enumerator.to_a.uniq
      member_scores = r.zrange("zset", 0, -1, :with_scores => true)

      assert member_scores.sort == scores_from_scan.sort
    end
  end

  def test_zscan_each_enumerator_match
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << j << "key:#{j}" }
      r.zadd "zset", elements

      scores_from_scan = r.zscan_each("zset", :match => "key:1??").to_a.uniq
      member_scores = r.zrange("zset", 0, -1, :with_scores => true)
      filtered_members = member_scores.select{|k,s| k =~ /^key:1..$/}

      assert filtered_members.sort == scores_from_scan.sort
    end
  end

  def test_zscan_each_block
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << j << "key:#{j}" }
      r.zadd "zset", elements

      scores_from_scan = []
      r.zscan_each("zset") do |member, score|
        scores_from_scan << [member, score]
      end
      member_scores = r.zrange("zset", 0, -1, :with_scores => true)

      assert member_scores.sort == scores_from_scan.sort
    end
  end

  def test_zscan_each_block_match
    target_version "2.7.105" do
      count = 1000
      elements = []
      count.times { |j| elements << j << "key:#{j}" }
      r.zadd "zset", elements

      scores_from_scan = []
      r.zscan_each("zset", :match => "key:1??") do |member, score|
        scores_from_scan << [member, score]
      end
      member_scores = r.zrange("zset", 0, -1, :with_scores => true)
      filtered_members = member_scores.select{|k,s| k =~ /^key:1..$/}

      assert filtered_members.sort == scores_from_scan.sort
    end
  end

end
