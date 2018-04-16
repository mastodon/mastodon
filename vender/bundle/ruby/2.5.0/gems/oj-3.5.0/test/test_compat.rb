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

class CompatJuice < Minitest::Test

  class Jeez
    attr_accessor :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def eql?(o)
      self.class == o.class && @x == o.x && @y == o.y
    end
    alias == eql?

    def to_json(*a)
      %|{"json_class":"#{self.class.to_s}","x":#{@x},"y":#{@y}}|
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end # Jeez

  class Argy
    def initialize()
    end

    def to_json(*a)
      %|{"args":"#{a}"}|
    end
  end # Argy

  class Stringy
    def initialize()
    end

    def to_s()
      %|[1,2]|
    end
  end # Stringy

  module One
    module Two
      module Three
        class Deep

          def initialize()
          end

          def eql?(o)
            self.class == o.class
          end
          alias == eql?

          def to_json(*a)
            %|{"json_class":"#{self.class.name}"}|
          end

          def self.json_create(h)
            self.new()
          end
        end # Deep
      end # Three
    end # Two
  end # One

  def setup
    @default_options = Oj.default_options
    # in compat mode other options other than the JSON gem globals and options
    # are not used.
    Oj.default_options = { :mode => :compat }
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
    dump_and_load(0.56, false)
    dump_and_load(3.0, false)
    dump_and_load(12345.6789, false)
    dump_and_load(70.35, false)
    dump_and_load(-54321.012, false)
    dump_and_load(1.7775, false)
    dump_and_load(2.5024, false)
    dump_and_load(2.48e16, false)
    dump_and_load(2.48e100 * 1.0e10, false)
    dump_and_load(-2.48e100 * 1.0e10, false)
    dump_and_load(1405460727.723866, false)
    dump_and_load(0.5773, false)
    dump_and_load(0.6768, false)
    dump_and_load(0.685, false)
    dump_and_load(0.7032, false)
    dump_and_load(0.7051, false)
    dump_and_load(0.8274, false)
    dump_and_load(0.9149, false)
    dump_and_load(64.4, false)
    dump_and_load(71.6, false)
    dump_and_load(73.4, false)
    dump_and_load(80.6, false)
    dump_and_load(-95.640172, false)
  end

  def test_string
    dump_and_load('', false)
    dump_and_load('abc', false)
    dump_and_load("abc\ndef", false)
    dump_and_load("a\u0041", false)
  end

  def test_encode
    opts = Oj.default_options
    Oj.default_options = { :ascii_only => false }
    unless 'jruby' == $ruby
      dump_and_load("ぴーたー", false)
    end
    Oj.default_options = { :ascii_only => true }
    json = Oj.dump("ぴーたー")
    assert_equal(%{"\\u3074\\u30fc\\u305f\\u30fc"}, json)
    unless 'jruby' == $ruby
      dump_and_load("ぴーたー", false)
    end
    Oj.default_options = opts
  end

  def test_unicode
    # hits the 3 normal ranges and one extended surrogate pair
    json = %{"\\u019f\\u05e9\\u3074\\ud834\\udd1e"}
    obj = Oj.load(json)
    json2 = Oj.dump(obj, :ascii_only => true)
    assert_equal(json, json2)
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

  def test_symbol
    json = Oj.dump(:abc, :mode => :compat)
    assert_equal('"abc"', json)
  end

  def test_time
    t = Time.xmlschema("2012-01-05T23:58:07.123456000+09:00")
    #t = Time.local(2012, 1, 5, 23, 58, 7, 123456)
    json = Oj.dump(t, :mode => :compat)
    assert_equal(%{"2012-01-05 23:58:07 +0900"}, json)
  end

  def test_class
    json = Oj.dump(CompatJuice, :mode => :compat)
    assert_equal(%{"CompatJuice"}, json)
  end

  def test_module
    json = Oj.dump(One::Two, :mode => :compat)
    assert_equal(%{"CompatJuice::One::Two"}, json)
  end

  # Hash
  def test_non_str_hash
    json = Oj.dump({ 1 => true, 0 => false }, :mode => :compat)
    h = Oj.load(json, :mode => :strict)
    assert_equal({ "1" => true, "0" => false }, h)
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
    obj = Oj.compat_load(json)
    assert_equal({"a\nb" => true, "c\td" => false}, obj)
  end

  def test_bignum_object
    dump_and_load(7 ** 55, false)
  end

  def test_json_object
    obj = Jeez.new(true, 58)
    json = Oj.to_json(obj)
    assert(%|{"json_class":"CompatJuice::Jeez","x":true,"y":58}| == json ||
          %|{"json_class":"CompatJuice::Jeez","y":58,"x":true}| == json)
    dump_to_json_and_load(obj, false)
  end

  def test_json_object_create_id
    Oj.default_options = { :create_id => 'kson_class', :create_additions => true}
    expected = Jeez.new(true, 58)
    json = %{{"kson_class":"CompatJuice::Jeez","x":true,"y":58}}
    obj = Oj.load(json)
    assert_equal(expected, obj)
    Oj.default_options = { :create_id => 'json_class' }
  end

  def test_bignum_compat
    json = Oj.dump(7 ** 55, :mode => :compat)
    b = Oj.load(json, :mode => :strict)
    assert_equal(30226801971775055948247051683954096612865741943, b)
  end

  # BigDecimal
  def test_bigdecimal
    # BigDecimals are dumped as strings and can not be restored to the
    # original value.
    json = Oj.dump(BigDecimal('3.14159265358979323846'))
    # 2.4.0 changes the exponent to lowercase
    assert_equal('"0.314159265358979323846e1"', json.downcase)
  end

  def test_infinity
    assert_raises(Oj::ParseError) { Oj.load('Infinity', :mode => :strict) }
    x = Oj.load('Infinity', :mode => :compat)
    assert_equal('Infinity', x.to_s)
  end

  # Time
  def test_time
    t = Time.new(2015, 1, 5, 21, 37, 7.123456, -8 * 3600)
    expect = '"' + t.to_s + '"'
    json = Oj.dump(t)
    assert_equal(expect, json)
  end

  def test_date_compat
    orig = Date.new(2012, 6, 19)
    json = Oj.dump(orig, :mode => :compat)
    x = Oj.load(json, :mode => :compat)
    # Some Rubies implement Date as data and some as a real Object. Either are
    # okay for the test.
    if x.is_a?(String)
      assert_equal(orig.to_s, x)
    else # better be a Hash
      assert_equal({"year" => orig.year, "month" => orig.month, "day" => orig.day, "start" => orig.start}, x)
    end
  end

  def test_datetime_compat
    orig = DateTime.new(2012, 6, 19, 20, 19, 27)
    json = Oj.dump(orig, :mode => :compat)
    x = Oj.load(json, :mode => :compat)
    # Some Rubies implement Date as data and some as a real Object. Either are
    # okay for the test.
    assert_equal(orig.to_s, x)
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
    obj = Oj.compat_load(input)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
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
    obj = Oj.compat_load(f)
    f.close()
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  # symbol_keys option
  def test_symbol_keys
    json = %{{
  "x":true,
  "y":58,
  "z": [1,2,3]
}
}
    obj = Oj.compat_load(json, :symbol_keys => true)
    assert_equal({ :x => true, :y => 58, :z => [1, 2, 3]}, obj)
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
    obj = Oj.compat_load(json)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  def test_comment_c
    json = %{{
  "x"/*one*/:/*two*/true,
  "y":58,
  "z": [1,2,3]}
}
    obj = Oj.compat_load(json)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
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
    obj = Oj.compat_load(json)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  # If mimic_JSON has not been called then Oj.dump will call to_json on the
  # top level object only.
  def test_json_object_top
    obj = Jeez.new(true, 58)
    dump_to_json_and_load(obj, false)
  end

  # A child to_json should not be called.
  def test_json_object_child
    obj = { "child" => Jeez.new(true, 58) }
    assert_equal('{"child":{"json_class":"CompatJuice::Jeez","x":true,"y":58}}', Oj.dump(obj))
  end

  def test_json_module_object
    obj = One::Two::Three::Deep.new()
    dump_to_json_and_load(obj, false)
  end

  def test_json_object_dump_create_id
    expected = Jeez.new(true, 58)
    json = Oj.to_json(expected)
    obj = Oj.compat_load(json, :create_additions => true)
    assert_equal(expected, obj)
  end

  def test_json_object_bad
    json = %{{"json_class":"CompatJuice::Junk","x":true}}
    begin
      Oj.compat_load(json, :create_additions => true)
    rescue Exception => e
      assert_equal("ArgumentError", e.class().name)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_json_object_create_cache
    expected = Jeez.new(true, 58)
    json = Oj.to_json(expected)
    obj = Oj.compat_load(json, :class_cache => true, :create_additions => true)
    assert_equal(expected, obj)
    obj = Oj.compat_load(json, :class_cache => false, :create_additions => true)
    assert_equal(expected, obj)
  end

  def test_json_object_create_id_other
    expected = Jeez.new(true, 58)
    json = Oj.to_json(expected)
    json.gsub!('json_class', '_class_')
    obj = Oj.compat_load(json, :create_id => "_class_", :create_additions => true)
    assert_equal(expected, obj)
  end

  def test_json_object_create_deep
    expected = One::Two::Three::Deep.new()
    json = Oj.to_json(expected)
    obj = Oj.compat_load(json, :create_additions => true)
    assert_equal(expected, obj)
  end

  def test_range
    json = Oj.dump(1..7)
    assert_equal('"1..7"', json)
  end

  def test_arg_passing
    json = Oj.to_json(Argy.new(), :max_nesting=> 40)
    assert_equal(%|{"args":"[{:max_nesting=>40}]"}|, json)
  end

  def test_bad_unicode
    assert_raises() { Oj.to_json("\xE4xy") }
  end

  def test_bad_unicode_e2
    assert_raises() { Oj.to_json("L\xE2m ") }
  end

  def test_bad_unicode_start
    assert_raises() { Oj.to_json("\x8abc") }
  end

  def test_parse_to_s
    s = Stringy.new
    assert_equal([1,2], Oj.load(s, :mode => :compat))
  end

  def dump_and_load(obj, trace=false)
    json = Oj.dump(obj)
    puts json if trace
    loaded = Oj.compat_load(json, :create_additions => true);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

  def dump_to_json_and_load(obj, trace=false)
    json = Oj.to_json(obj, :indent => '  ')
    puts json if trace
    loaded = Oj.compat_load(json, :create_additions => true);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

end
