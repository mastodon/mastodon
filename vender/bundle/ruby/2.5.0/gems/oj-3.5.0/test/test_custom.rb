#!/usr/bin/env ruby
# encoding: utf-8

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
require 'oj'

class CustomJuice < Minitest::Test

  module TestModule
  end

  class Jeez
    attr_accessor :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end
    def ==(o)
      self.class == o.class && @x == o.x && @y = o.y
    end
    def to_json(*args)
      %|{"xx":#{@x},"yy":#{y}}|
    end
    def as_json(*args)
      {'a' => @x, :b => @y }
    end
    def to_hash()
      {'b' => @x, 'n' => @y }
    end
  end

  def setup
    @default_options = Oj.default_options
    Oj.default_options = { :mode => :custom }
  end

  def teardown
    Oj.default_options = @default_options
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
    assert_equal('null', Oj.dump(0/0.0, :nan => :null))
    assert_equal('3.3e14159265358979323846', Oj.dump(0/0.0, :nan => :huge))
    assert_equal('NaN', Oj.dump(0/0.0, :nan => :word))
    begin
      Oj.dump(0/0.0, :nan => :raise)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end
  
  def test_infinity_dump
    assert_equal('null', Oj.dump(1/0.0, :nan => :null))
    assert_equal('3.0e14159265358979323846', Oj.dump(1/0.0, :nan => :huge))
    assert_equal('Infinity', Oj.dump(1/0.0, :nan => :word))
    begin
      Oj.dump(1/0.0, :nan => :raise)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_neg_infinity_dump
    assert_equal('null', Oj.dump(-1/0.0, :nan => :null))
    assert_equal('-3.0e14159265358979323846', Oj.dump(-1/0.0, :nan => :huge))
    assert_equal('-Infinity', Oj.dump(-1/0.0, :nan => :word))
    begin
      Oj.dump(-1/0.0, :nan => :raise)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_string
    dump_and_load('', false)
    dump_and_load('abc', false)
    dump_and_load("abc\ndef", false)
    dump_and_load("a\u0041", false)
  end

  def test_string_ascii
    json = Oj.dump("ぴーたー", :escape_mode => :ascii)
    assert_equal(%{"\\u3074\\u30fc\\u305f\\u30fc"}, json)
    dump_and_load("ぴーたー", false, :escape_mode => :ascii)
  end

  def test_string_json
    json = Oj.dump("ぴーたー", :escape_mode => :json)
    assert_equal(%{"ぴーたー"}, json)
    dump_and_load("ぴーたー", false, :escape_mode => :json)
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
      Oj.strict_load('[' * n + ']' * n)
    rescue Exception => e
      assert(false, e.message)
    end
  end

  def test_hash
    dump_and_load({}, false)
    dump_and_load({ 'true' => true, 'false' => false}, false)
    dump_and_load({ 'true' => true, 'array' => [], 'hash' => { }}, false)
  end

  def test_hash_deep
    dump_and_load({'1' => {
                      '2' => {
                        '3' => {
                          '4' => {
                            '5' => {
                              '6' => {
                                '7' => {
                                  '8' => {
                                    '9' => {
                                      '10' => {
                                        '11' => {
                                          '12' => {
                                            '13' => {
                                              '14' => {
                                                '15' => {
                                                  '16' => {
                                                    '17' => {
                                                      '18' => {
                                                        '19' => {
                                                          '20' => {}}}}}}}}}}}}}}}}}}}}}, false)
  end
  
  def test_hash_escaped_key
    json = %{{"a\nb":true,"c\td":false}}
    obj = Oj.load(json)
    assert_equal({"a\nb" => true, "c\td" => false}, obj)
  end

  def test_hash_non_string_key
    assert_equal(%|{"1":true}|, Oj.dump({ 1 => true }, :indent => 0))
  end

  def test_bignum_object
    dump_and_load(7 ** 55, false)
  end

  def test_bigdecimal
    assert_equal('0.314159265358979323846e1', Oj.dump(BigDecimal('3.14159265358979323846'), bigdecimal_as_decimal: true).downcase())
    assert_equal('"0.314159265358979323846e1"', Oj.dump(BigDecimal('3.14159265358979323846'), bigdecimal_as_decimal: false).downcase())
    dump_and_load(BigDecimal('3.14159265358979323846'), false, :bigdecimal_load => true)
  end

  def test_object
    obj = Jeez.new(true, 58)
    Oj.dump(obj, :create_id => "^o", :use_to_json => false, :use_as_json => false, :use_to_hash => false)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_object_to_json
    obj = Jeez.new(true, 58)
    json = Oj.dump(obj, :use_to_json => true, :use_as_json => false, :use_to_hash => false)
    assert_equal(%|{"xx":true,"yy":58}|, json)
  end

  def test_object_as_json
    obj = Jeez.new(true, 58)
    json = Oj.dump(obj, :use_to_json => false, :use_as_json => true, :use_to_hash => false)
    assert_equal(%|{"a":true,"b":58}|, json)
  end

  def test_object_to_hash
    obj = Jeez.new(true, 58)
    json = Oj.dump(obj, :use_to_json => false, :use_as_json => false, :use_to_hash => true)
    assert_equal(%|{"b":true,"n":58}|, json)
  end

  def test_symbol
    json = Oj.dump(:abc)
    assert_equal('"abc"', json)
  end

  def test_class
    assert_equal(%|"CustomJuice"|, Oj.dump(CustomJuice))
  end

  def test_module
    assert_equal(%|"CustomJuice::TestModule"|, Oj.dump(TestModule))
  end

  def test_symbol_keys
    json = %|{
  "x":true,
  "y":58,
  "z": [1,2,3]
}
|
    obj = Oj.load(json, :symbol_keys => true)
    assert_equal({ :x => true, :y => 58, :z => [1, 2, 3]}, obj)
  end

  def test_double
    json = %{{ "x": 1}{ "y": 2}}
    results = []
    Oj.load(json, :mode => :strict) { |x| results << x }

    assert_equal([{ 'x' => 1 }, { 'y' => 2 }], results)
  end

  def test_circular_hash
    h = { 'a' => 7 }
    h['b'] = h
    json = Oj.dump(h, :indent => 2, :circular => true)
    assert_equal(%|{
  "a":7,
  "b":null
}
|, json)
  end

  def test_omit_nil
    json = Oj.dump({'x' => {'a' => 1, 'b' => nil }, 'y' => nil}, :omit_nil => true)
    assert_equal(%|{"x":{"a":1}}|, json)
  end

  def test_complex
    obj = Complex(2, 9)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_rational
    obj = Rational(2, 9)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_range
    obj = 3..8
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_date
    obj = Date.new(2017, 1, 5)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_datetime
    obj = DateTime.new(2017, 1, 5, 10, 20, 30)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_regexp
    # this notation must be used to get an == match later
    obj = /(?ix-m:^yes$)/
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_openstruct
    obj = OpenStruct.new(:a => 1, 'b' => 2)
    dump_and_load(obj, false, :create_id => "^o", :create_additions => true)
  end

  def test_time
    obj = Time.now()
    dump_and_load(obj, false, :time_format => :unix, :create_id => "^o", :create_additions => true)
    dump_and_load_inspect(obj, false, :time_format => :unix_zone, :create_id => "^o", :create_additions => true)
    dump_and_load_inspect(obj, false, :time_format => :xmlschema, :create_id => "^o", :create_additions => true)
    dump_and_load_inspect(obj, false, :time_format => :ruby, :create_id => "^o", :create_additions => true)
  end

  def dump_and_load(obj, trace=false, options={})
    options = options.merge(:indent => 2, :mode => :custom)
    json = Oj.dump(obj, options)
    puts json if trace

    loaded = Oj.load(json, options);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

  def dump_and_load_inspect(obj, trace=false, options={})
    options = options.merge(:indent => 2, :mode => :custom)
    json = Oj.dump(obj, options)
    puts json if trace

    loaded = Oj.load(json, options);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj.inspect, loaded.inspect)
    end
    loaded
  end

end
