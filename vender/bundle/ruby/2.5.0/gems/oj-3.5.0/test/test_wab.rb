#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)
$oj_dir = File.dirname(File.expand_path(File.dirname(__FILE__)))
%w(lib ext).each do |dir|
  $: << File.join($oj_dir, dir)
end

require 'minitest'
require 'minitest/autorun'
require 'stringio'
require 'date'
require 'bigdecimal'
require 'uri'
require 'oj'

# Simple version of WAB::UUID for testing.
module WAB
  class UUID
    attr_reader :id
    def initialize(id)
      @id = id.downcase
      raise Exception.new("Invalid UUID format.") if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match(@id).nil?
    end
    def to_s
      @id
    end
    def ==(other)
      other.is_a?(self.class) && @id == other.id
    end
  end # UUID
end # WAB


class WabJuice < Minitest::Test

  module TestModule
  end

  def test_nil
    dump_and_load(nil, false)
  end

  def test_true
    dump_and_load(true, false)
  end

  def test_false
    dump_and_load(false, false)
  end

  def test_fixnum
    dump_and_load(0, false)
    dump_and_load(12345, false)
    dump_and_load(-54321, false)
    dump_and_load(1, false)
  end

  def test_float
    dump_and_load(0.0, false)
    dump_and_load(12345.6789, false)
    dump_and_load(70.35, false)
    dump_and_load(-54321.012, false)
    dump_and_load(1.7775, false)
    dump_and_load(2.5024, false)
    dump_and_load(2.48e16, false)
    dump_and_load(2.48e100 * 1.0e10, false)
    dump_and_load(-2.48e100 * 1.0e10, false)
  end

  def test_nan_dump
    assert_raises() { Oj.dump(0/0.0, mode: :wab) }
  end

  def test_infinity_dump
    assert_raises() { Oj.dump(1/0.0, mode: :wab) }
  end

  def test_neg_infinity_dump
    assert_raises() { Oj.dump(-1/0.0, mode: :wab) }
  end

  def test_string
    dump_and_load('', false)
    dump_and_load('abc', false)
    dump_and_load("abc\ndef", false)
    dump_and_load("a\u0041", false)
  end

  def test_encode
    dump_and_load("ぴーたー", false)
  end

  def test_array
    dump_and_load([], false)
    dump_and_load([true, false], false)
    dump_and_load(['a', 1, nil], false)
    dump_and_load([[nil]], false)
    dump_and_load([[nil], 58], false)
  end

  def test_array_deep
    dump_and_load([1,[2,[3,[4,[5,[6,[7,[8,[9,[10,[11,[12,[13,[14,[15,[16,[17,[18,[19,[20]]]]]]]]]]]]]]]]]]]], false)
  end

  def test_deep_nest
    begin
      n = 10000
      Oj.wab_load('[' * n + ']' * n)
    rescue Exception => e
      assert(false, e.message)
    end
  end

  # Hash
  def test_hash
    dump_and_load({}, false)
    dump_and_load({ true: true, false: false}, false)
    dump_and_load({ true: true, array: [], hash: { }}, false)
  end

  def test_hash_non_sym_keys
    assert_raises() { Oj.dump({ 'true' => true}, mode: :wab) }
  end

  def test_hash_deep
    dump_and_load({x1: {
                      x2: {
                        x3: {
                          x4: {
                            x5: {
                              x6: {
                                x7: {
                                  x8: {
                                    x9: {
                                      x10: {
                                        x11: {
                                          x12: {
                                            x13: {
                                              x14: {
                                                x15: {
                                                  x16: {
                                                    x17: {
                                                      x18: {
                                                        x19: {
                                                          x20: {}}}}}}}}}}}}}}}}}}}}}, false)
  end

  def test_non_str_hash
    assert_raises() { Oj.dump({ 1 => true, 0 => false }, mode: :wab) }
  end

  def test_bignum_object
    dump_and_load(7 ** 55, false)
  end

  # BigDecimal
  def test_bigdecimal_wab
    dump_and_load(BigDecimal('3.14159265358979323846'), false)
  end

  def test_bigdecimal_load
    orig = BigDecimal('80.51')
    json = Oj.dump(orig, mode: :wab)
    bg = Oj.load(json, :mode => :wab, :bigdecimal_load => true)
    assert_equal(BigDecimal, bg.class)
    assert_equal(orig, bg)
  end

  def test_range
    assert_raises() { Oj.dump(1..7, mode: :wab) }
  end

  # Stream IO
  def test_io_string
    json = %{{
  "x":true,
  "y":58,
  "z": [1,2,3]
}
}
    input = StringIO.new(json)
    obj = Oj.wab_load(input)
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  def test_io_file
    filename = File.join(File.dirname(__FILE__), 'open_file_test.json')
    File.open(filename, 'w') { |f| f.write(%{{
  "x":true,
  "y":58,
  "z": [1,2,3]
}
}) }
    f = File.new(filename)
    obj = Oj.wab_load(f)
    f.close()
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  def test_symbol
    json = Oj.dump(:abc, mode: :wab)
    assert_equal('"abc"', json)
  end

  def test_time
    t = Time.gm(2017, 1, 5, 23, 58, 7, 123456.789)
    json = Oj.dump(t, mode: :wab)
    assert_equal('"2017-01-05T23:58:07.123456789Z"', json)
    # must load and convert to json as the Time#== does not match identical
    # times due to the way it tracks fractional seconds.
    loaded = Oj.wab_load(json);
    assert_equal(json, Oj.dump(loaded, mode: :wab), "json mismatch after load")
  end

  def test_uuid
    u = ::WAB::UUID.new('123e4567-e89b-12d3-a456-426655440000')
    json = Oj.dump(u, mode: :wab)
    assert_equal('"123e4567-e89b-12d3-a456-426655440000"', json)
    dump_and_load(u, false)
  end

  def test_uri
    u = URI('http://opo.technology/sample')
    json = Oj.dump(u, mode: :wab)
    assert_equal('"http://opo.technology/sample"', json)
    dump_and_load(u, false)
  end

  def test_class
    assert_raises() { Oj.dump(WabJuice, mode: :wab) }
  end

  def test_module
    assert_raises() { Oj.dump(TestModule, mode: :wab) }
  end

  # symbol_keys option
  def test_symbol_keys
    json = %{{
  "x":true,
  "y":58,
  "z": [1,2,3]
}
}
    obj = Oj.wab_load(json, :symbol_keys => true)
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  # comments
  def test_comment_slash
    json = %{{
  "x":true,//three
  "y":58,
  "z": [1,2,
3 // six
]}
}
    obj = Oj.wab_load(json)
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  def test_comment_c
    json = %{{
  "x"/*one*/:/*two*/true,
  "y":58,
  "z": [1,2,3]}
}
    obj = Oj.wab_load(json)
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  def test_comment
    json = %{{
  "x"/*one*/:/*two*/true,//three
  "y":58/*four*/,
  "z": [1,2/*five*/,
3 // six
]
}
}
    obj = Oj.wab_load(json)
    assert_equal({ x: true, y: 58, z: [1, 2, 3]}, obj)
  end

  def test_double
    json = %{{ "x": 1}{ "y": 2}}
    results = []
    Oj.load(json, :mode => :wab) { |x| results << x }

    assert_equal([{ x: 1 }, { y: 2 }], results)
  end

  def dump_and_load(obj, trace=false)
    json = Oj.dump(obj, mode: :wab, indent: 2)
    puts json if trace
    loaded = Oj.wab_load(json);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

end
