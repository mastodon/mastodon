#!/usr/bin/env ruby
# encoding: utf-8

$: << File.dirname(__FILE__)

require 'helper'

class Juice < Minitest::Test
  def gen_whitespaced_string(length = Random.new.rand(100))
    whitespace_chars = [" ", "\t", "\f", "\n", "\r"]
    result = ""
    length.times { result << whitespace_chars.sample }
    result
  end

  module TestModule
  end

  class Jam
    attr_accessor :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def eql?(o)
      self.class == o.class && @x == o.x && @y == o.y
    end
    alias == eql?

  end# Jam

  class Jeez < Jam
    def initialize(x, y)
      super
    end

    def to_json()
      %{{"json_class":"#{self.class}","x":#{@x},"y":#{@y}}}
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end# Jeez

  # contributed by sauliusg to fix as_json
  class Orange < Jam
    def initialize(x, y)
      super
    end

    def as_json()
      { :json_class => self.class,
        :x => @x,
        :y => @y }
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end

  class Melon < Jam
    def initialize(x, y)
      super
    end

    def as_json(options)
      "#{x} #{y}"
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end

  class Jazz < Jam
    def initialize(x, y)
      super
    end
    def to_hash()
      { 'json_class' => self.class.to_s, 'x' => @x, 'y' => @y }
    end
    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end# Jazz

  def setup
    @default_options = Oj.default_options
  end

  def teardown
    Oj.default_options = @default_options
  end

=begin
  # Depending on the order the values may have changed. The set_options sets
  # should cover the function itself.
  def test_get_options
    opts = Oj.default_options()
    assert_equal({ :indent=>0,
                   :second_precision=>9,
                   :circular=>false,
                   :class_cache=>true,
                   :auto_define=>false,
                   :symbol_keys=>false,
                   :bigdecimal_as_decimal=>true,
                   :use_to_json=>true,
                   :nilnil=>false,
                   :allow_gc=>true,
                   :quirks_mode=>true,
                   :allow_invalid_unicode=>false,
                   :float_precision=>15,
                   :mode=>:object,
                   :escape_mode=>:json,
                   :time_format=>:unix_zone,
                   :bigdecimal_load=>:auto,
                   :create_id=>'json_class'}, opts)
  end
=end
  def test_set_options
    orig = Oj.default_options()
    alt ={
      :indent=>" - ",
      :second_precision=>5,
      :circular=>true,
      :class_cache=>false,
      :auto_define=>true,
      :symbol_keys=>true,
      :bigdecimal_as_decimal=>false,
      :use_to_json=>false,
      :use_to_hash=>false,
      :use_as_json=>false,
      :nilnil=>true,
      :empty_string=>true,
      :allow_gc=>false,
      :quirks_mode=>false,
      :allow_invalid_unicode=>true,
      :float_precision=>13,
      :mode=>:strict,
      :escape_mode=>:ascii,
      :time_format=>:unix_zone,
      :bigdecimal_load=>:float,
      :create_id=>'classy',
      :space=>'z',
      :array_nl=>'a',
      :object_nl=>'o',
      :space_before=>'b',
      :nan=>:huge,
      :hash_class=>Hash,
      :omit_nil=>false,
      :allow_nan=>true,
      :array_class=>Array,
      :ignore=>nil,
      :trace=>true,
    }
    Oj.default_options = alt
    #keys = alt.keys
    #Oj.default_options.keys.each { |k| puts k unless keys.include? k}
    opts = Oj.default_options()
    assert_equal(alt, opts);

    Oj.default_options = orig # return to original
    # verify back to original
    opts = Oj.default_options()
    assert_equal(orig, opts);
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

  def test_float_parse
    Oj.default_options = { :float_precision => 16, :bigdecimal_load => :auto }
    n = Oj.load('0.00001234567890123456')
    assert_equal(Float, n.class)
    assert_equal('1.234567890123456e-05', "%0.15e" % [n])

    n = Oj.load('-0.00001234567890123456')
    assert_equal(Float, n.class)
    assert_equal('-1.234567890123456e-05', "%0.15e" % [n])

    n = Oj.load('1000.0000123456789')
    assert_equal(BigDecimal, n.class)
    assert_equal('0.10000000123456789E4', n.to_s.upcase)

    n = Oj.load('-0.000012345678901234567')
    assert_equal(BigDecimal, n.class)
    assert_equal('-0.12345678901234567E-4', n.to_s.upcase)

  end

=begin
# TBD move to custom
  def test_float_dump
    Oj.default_options = { :float_precision => 16 }
    assert_equal('1405460727.723866', Oj.dump(1405460727.723866))
    Oj.default_options = { :float_precision => 5 }
    assert_equal('1.4055', Oj.dump(1.405460727))
    Oj.default_options = { :float_precision => 0 }
    assert_equal('1405460727.723866', Oj.dump(1405460727.723866))
    Oj.default_options = { :float_precision => 15 }
    assert_equal('0.56', Oj.dump(0.56))
    assert_equal('0.5773', Oj.dump(0.5773))
    assert_equal('0.6768', Oj.dump(0.6768))
    assert_equal('0.685', Oj.dump(0.685))
    assert_equal('0.7032', Oj.dump(0.7032))
    assert_equal('0.7051', Oj.dump(0.7051))
    assert_equal('0.8274', Oj.dump(0.8274))
    assert_equal('0.9149', Oj.dump(0.9149))
    assert_equal('64.4', Oj.dump(64.4))
    assert_equal('71.6', Oj.dump(71.6))
    assert_equal('73.4', Oj.dump(73.4))
    assert_equal('80.6', Oj.dump(80.6))
    assert_equal('-95.640172', Oj.dump(-95.640172))
  end
=end

  def test_string
    dump_and_load('', false)
    dump_and_load('abc', false)
    dump_and_load("abc\ndef", false)
    dump_and_load("a\u0041", false)
    assert_equal("a\u0000a", dump_and_load("a\u0000a", false))
  end

  def test_encode
    opts = Oj.default_options
    Oj.default_options = { :ascii_only => false }
    dump_and_load("ぴーたー", false)

    Oj.default_options = { :ascii_only => true }
    json = Oj.dump("ぴーたー")
    assert_equal(%{"\\u3074\\u30fc\\u305f\\u30fc"}, json)
    dump_and_load("ぴーたー", false)
    Oj.default_options = opts
  end

  def test_unicode
    # hits the 3 normal ranges and one extended surrogate pair
    json = %{"\\u019f\\u05e9\\u3074\\ud834\\udd1e"}
    obj = Oj.load(json)
    json2 = Oj.dump(obj, :ascii_only => true)
    assert_equal(json, json2)
  end

  def test_invalid_unicode_raise
    # validate that an invalid unicode raises unless the :allow_invalid_unicode is true
    json = %{"x\\ud83dy"}
    begin
      Oj.load(json)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_invalid_unicode_ok
    # validate that an invalid unicode raises unless the :allow_invalid_unicode is true
    json = %{"x\\ud83dy"}
    obj = Oj.load(json, :allow_invalid_unicode => true)
    # The same as what ruby would do with the invalid encoding.
    assert_equal("x\xED\xA0\xBDy", obj.to_s)
  end

  def test_dump_options
    json = Oj.dump({ 'a' => 1, 'b' => [true, false]},
                   :mode => :compat,
                   :indent => "--",
                   :array_nl => "\n",
                   :object_nl => "#\n",
                   :space => "*",
                   :space_before => "~")
    assert(%{{#
--"a"~:*1,#
--"b"~:*[
----true,
----false
--]#
}} == json ||
%{{#
--"b"~:*[
----true,
----false
--],#
--"a"~:*1#
}} == json)

  end

  def test_null_char
    assert_raises(Oj::ParseError) { Oj.load("\"\0\"") }
    assert_raises(Oj::ParseError) { Oj.load("\"\\\0\"") }
  end

  def test_array
    dump_and_load([], false)
    dump_and_load([true, false], false)
    dump_and_load(['a', 1, nil], false)
    dump_and_load([[nil]], false)
    dump_and_load([[nil], 58], false)
  end
  def test_array_not_closed
    begin
      Oj.load('[')
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  # multiple JSON in one string
  def test_multiple_json_callback
    json = %{{"a":1}
[1,2][3,4]
{"b":2}
}
    results = []
    Oj.load(json, :mode => :strict) { |x, start, len| results << [x, start, len] }
    assert_equal([[{"a"=>1}, 0, 7], [[1,2], 7, 6], [[3,4], 13, 5], [{"b"=>2}, 18, 8]], results)
  end

  def test_multiple_json_no_callback
    json = %{{"a":1}
[1,2][3,4]
{"b":2}
}
    assert_raises(Oj::ParseError) { Oj.load(json) }
  end

  # encoding tests
  def test_does_not_escape_entities_by_default
    Oj.default_options = { :escape_mode => :ascii } # set in mimic mode
    # use Oj to create the hash since some Rubies don't deal nicely with unicode.
    json = %{{"key":"I <3 this\\u2028space"}}
    hash = Oj.load(json)
    out = Oj.dump(hash)
    assert_equal(json, out)
  end
  def test_escapes_entities_by_default_when_configured_to_do_so
    hash = {'key' => "I <3 this"}
    Oj.default_options = {:escape_mode => :xss_safe}
    out = Oj.dump hash
    assert_equal(%{{"key":"I \\u003c3 this"}}, out)
  end
  def test_escapes_entities_when_asked_to
    hash = {'key' => "I <3 this"}
    out = Oj.dump(hash, :escape_mode => :xss_safe)
    assert_equal(%{{"key":"I \\u003c3 this"}}, out)
  end
  def test_does_not_escape_entities_when_not_asked_to
    hash = {'key' => "I <3 this"}
    out = Oj.dump(hash, :escape_mode => :json)
    assert_equal(%{{"key":"I <3 this"}}, out)
  end
  def test_escapes_common_xss_vectors
    hash = {'key' => "<script>alert(123) && formatHD()</script>"}
    out = Oj.dump(hash, :escape_mode => :xss_safe)
    assert_equal(%{{"key":"\\u003cscript\\u003ealert(123) \\u0026\\u0026 formatHD()\\u003c\\/script\\u003e"}}, out)
  end
  def test_escape_newline_by_default
    Oj.default_options = { :escape_mode => :json }
    json = %{["one","two\\n2"]}
    x = Oj.load(json)
    out = Oj.dump(x)
    assert_equal(json, out)
  end
  def test_does_not_escape_newline
    Oj.default_options = { :escape_mode => :newline }
    json = %{["one","two\n2"]}
    x = Oj.load(json)
    out = Oj.dump(x)
    assert_equal(json, out)
  end

  # Symbol
  def test_symbol_null
    json = Oj.dump(:abc, :mode => :null)
    assert_equal('"abc"', json)
  end

  # Time
  def test_time_null
    t = Time.local(2012, 1, 5, 23, 58, 7)
    json = Oj.dump(t, :mode => :null)
    assert_equal('null', json)
  end

  # Class
  def test_class_null
    json = Oj.dump(Juice, :mode => :null)
    assert_equal('null', json)
  end

  # Module
  def test_module_null
    json = Oj.dump(TestModule, :mode => :null)
    assert_equal('null', json)
  end

  # Hash
  def test_non_str_hash_null
    begin
      Oj.dump({ 1 => true, 0 => false }, :mode => :null)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_hash_not_closed
    begin
      Oj.load('{')
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  # Object with to_json()
  def test_json_object_null
    obj = Jeez.new(true, 58)
    json = Oj.dump(obj, :mode => :null)
    assert_equal('null', json)
  end

# Object with to_hash()
  def test_to_hash_object_null
    obj = Jazz.new(true, 58)
    json = Oj.dump(obj, :mode => :null)
    assert_equal('null', json)
  end

  # Object with as_json() # contributed by sauliusg
  def test_as_json_object_null
    obj = Orange.new(true, 58)
    json = Oj.dump(obj, :mode => :null)
    assert_equal('null', json)
  end

  # Object without to_json() or to_hash()
  def test_object_null
    obj = Jam.new(true, 58)
    json = Oj.dump(obj, :mode => :null)
    assert_equal('null', json)
  end

  # Range
  def test_range_null
    json = Oj.dump(1..7, :mode => :null)
    assert_equal('null', json)
  end

  # BigNum
  def test_bignum_null
    json = Oj.dump(7 ** 55, :mode => :null)
    assert_equal('30226801971775055948247051683954096612865741943', json)
  end

  def test_bignum_object
    dump_and_load(7 ** 55, false)
    dump_and_load(10 ** 19, false)
  end

  # BigDecimal
  def test_bigdecimal_null
    mode = Oj.default_options[:mode]
    Oj.default_options = {:mode => :null}
    dump_and_load(BigDecimal('3.14159265358979323846'), false)
    Oj.default_options = {:mode => mode}
  end

  def test_infinity
    n = Oj.load('Infinity', :mode => :object)
    assert_equal(BigDecimal('Infinity').to_f, n);
    x = Oj.load('Infinity', :mode => :compat)
    assert_equal('Infinity', x.to_s)
  end

  # Date
  def test_date_null
    json = Oj.dump(Date.new(2012, 6, 19), :mode => :null)
    assert_equal('null', json)
  end

  # DateTime
  def test_datetime_null
    json = Oj.dump(DateTime.new(2012, 6, 19, 20, 19, 27), :mode => :null)
    assert_equal('null', json)
  end

  # autodefine Oj::Bag
  def test_bag
    json = %{{
  "^o":"Juice::Jem",
  "x":true,
  "y":58 }}
    obj = Oj.load(json, :mode => :object, :auto_define => true)
    assert_equal('Juice::Jem', obj.class.name)
    assert_equal(true, obj.x)
    assert_equal(58, obj.y)
  end

# Stream Deeply Nested
  def test_deep_nest_dump
    begin
      a = []
      10000.times { a << [a] }
      Oj.dump(a)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

# Stream IO
  def test_io_string
    src = { 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}
    output = StringIO.open("", "w+")
    Oj.to_stream(output, src)

    input = StringIO.new(output.string())
    obj = Oj.load(input, :mode => :strict)
    assert_equal(src, obj)
  end

  def test_io_file
    src = { 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}
    filename = File.join(File.dirname(__FILE__), 'open_file_test.json')
    File.open(filename, "w") { |f|
      Oj.to_stream(f, src)
    }
    f = File.new(filename)
    obj = Oj.load(f, :mode => :strict)
    f.close()
    assert_equal(src, obj)
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
    obj = Oj.load(json, :mode => :strict)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  def test_comment_c
    json = %{/*before*/
{
  "x"/*one*/:/*two*/true,
  "y":58,
  "z": [1,2,3]}
}
    obj = Oj.load(json, :mode => :strict)
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
    obj = Oj.load(json, :mode => :strict)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  def test_nilnil_false
    begin
      Oj.load(nil, :nilnil => false)
    rescue Exception
      assert(true)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_nilnil_true
    obj = Oj.load(nil, :nilnil => true)
    assert_nil(obj)
  end

  def test_empty_string_true
    result = Oj.load(gen_whitespaced_string, :empty_string => true, mode: :strict)
    assert_nil(result)
  end

  def test_empty_string_false
    # Could be either a Oj::ParseError or an EncodingError depending on
    # whether mimic_JSON has been called. Since we don't know when the test
    # will be called either is okay.
    begin
      Oj.load(gen_whitespaced_string, :empty_string => false)
    rescue Exception => e
      assert(Oj::ParseError == e.class || EncodingError == e.class)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_quirks_null_mode
    assert_raises(Oj::ParseError) { Oj.load("null", :quirks_mode => false) }
    assert_nil(Oj.load("null", :quirks_mode => true))
  end

  def test_quirks_bool_mode
    assert_raises(Oj::ParseError) { Oj.load("true", :quirks_mode => false) }
    assert_equal(true, Oj.load("true", :quirks_mode => true))
  end

  def test_quirks_number_mode
    assert_raises(Oj::ParseError) { Oj.load("123", :quirks_mode => false) }
    assert_equal(123, Oj.load("123", :quirks_mode => true))
  end

  def test_quirks_decimal_mode
    assert_raises(Oj::ParseError) { Oj.load("123.45", :quirks_mode => false) }
    assert_equal(123.45, Oj.load("123.45", :quirks_mode => true))
  end

  def test_quirks_string_mode
    assert_raises(Oj::ParseError) { Oj.load('"string"', :quirks_mode => false) }
    assert_equal('string', Oj.load('"string"', :quirks_mode => true))
  end

  def test_quirks_array_mode
    assert_equal([], Oj.load("[]", :quirks_mode => false))
    assert_equal([], Oj.load("[]", :quirks_mode => true))
  end

  def test_quirks_object_mode
    assert_equal({}, Oj.load("{}", :quirks_mode => false))
    assert_equal({}, Oj.load("{}", :quirks_mode => true))
  end

  def test_omit_nil
    jam = Jam.new({'a' => 1, 'b' => nil }, nil)

    json = Oj.dump(jam, :omit_nil => true, :mode => :object)
    assert_equal(%|{"^o":"Juice::Jam","x":{"a":1}}|, json)

    json = Oj.dump({'x' => {'a' => 1, 'b' => nil }, 'y' => nil}, :omit_nil => true, :mode => :strict)
    assert_equal(%|{"x":{"a":1}}|, json)

    json = Oj.dump({'x' => {'a' => 1, 'b' => nil }, 'y' => nil}, :omit_nil => true, :mode => :null)
    assert_equal(%|{"x":{"a":1}}|, json)
  end

  def dump_and_load(obj, trace=false)
    json = Oj.dump(obj, :indent => 2)
    puts json if trace
    loaded = Oj.load(json)
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

end
