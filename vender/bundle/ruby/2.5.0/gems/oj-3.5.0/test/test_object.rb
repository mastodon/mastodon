#!/usr/bin/env ruby
# encoding: utf-8

$: << File.dirname(__FILE__)

require 'helper'

class ObjectJuice < Minitest::Test
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
      %{{"json_class":"#{self.class}","x":#{@x},"y":#{@y}}}
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end
  end # Jeez

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

  end # Jam

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
  end # Jazz

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

          def to_hash()
            {'json_class' => "#{self.class.name}"}
          end

          def to_json(*a)
            %{{"json_class":"#{self.class.name}"}}
          end

          def self.json_create(h)
            self.new()
          end
        end # Deep
      end # Three
    end # Two

    class Stuck2 < Struct.new(:a, :b)
    end

  end # One

  class Stuck < Struct.new(:a, :b)
  end

  class Strung < String

    def initialize(str, safe)
      super(str)
      @safe = safe
    end

    def safe?()
      @safe
    end

    def self.create(str, safe)
      new(str, safe)
    end

    def eql?(o)
      super && self.class == o.class && @safe == o.safe?
    end
    alias == eql?

    def inspect()
      return super + '(' + @safe + ')'
    end
  end

  class AutoStrung < String
    attr_accessor :safe

    def initialize(str, safe)
      super(str)
      @safe = safe
    end

    def eql?(o)
      self.class == o.class && super(o) && @safe == o.safe
    end
    alias == eql?
  end

  class AutoArray < Array
    attr_accessor :safe

    def initialize(a, safe)
      super(a)
      @safe = safe
    end

    def eql?(o)
      self.class == o.class && super(o) && @safe == o.safe
    end
    alias == eql?
  end

  class AutoHash < Hash
    attr_accessor :safe

    def initialize(h, safe)
      super(h)
      @safe = safe
    end

    def eql?(o)
      self.class == o.class && super(o) && @safe == o.safe
    end
    alias == eql?
  end

  class Raw
    attr_accessor :json

    def initialize(j)
      @json = j
    end

    def to_json(*a)
      @json
    end

    def self.create(h)
      h
    end
  end # Raw

  module Ichi
    module Ni
      def self.direct(h)
        h
      end

      module San
        class Shi

          attr_accessor :hash

          def initialize(h)
            @hash = h
          end

          def dump()
            @hash
          end

        end # Shi
      end # San
    end # Ni
  end # Ichi

  def setup
    @default_options = Oj.default_options
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
    dump_and_load(1/0.0, false)
    # NaN does not always == NaN
    json = Oj.dump(0/0.0, :mode => :object)
    assert_equal('3.3e14159265358979323846', json)
    loaded = Oj.load(json);
    assert_equal(true, loaded.nan?)
  end

  def test_string
    dump_and_load('', false)
    dump_and_load('abc', false)
    dump_and_load("abc\ndef", false)
    dump_and_load("a\u0041", false)
  end

  def test_symbol
    dump_and_load(:abc, false)
    dump_and_load(":abc", false)
    dump_and_load(':xyz'.to_sym, false)
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

  # Hash
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
    obj = Oj.object_load(json)
    assert_equal({"a\nb" => true, "c\td" => false}, obj)
  end

  def test_bignum_object
    dump_and_load(7 ** 55, false)
  end

  # BigDecimal
  def test_bigdecimal_object
    dump_and_load(BigDecimal('3.14159265358979323846'), false)
  end

  def test_bigdecimal_load
    orig = BigDecimal('80.51')
    json = Oj.dump(orig, :mode => :object, :bigdecimal_as_decimal => true)
    bg = Oj.load(json, :mode => :object, :bigdecimal_load => true)
    assert_equal(BigDecimal, bg.class)
    assert_equal(orig, bg)
    # Infinity is the same for Float and BigDecimal
    json = Oj.dump(BigDecimal('Infinity'), :mode => :object)
    assert_equal('Infinity', json)
    json = Oj.dump(BigDecimal('-Infinity'), :mode => :object)
    assert_equal('-Infinity', json)
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
    obj = Oj.object_load(input)
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
    obj = Oj.object_load(f)
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
    obj = Oj.object_load(json, :symbol_keys => true)
    assert_equal({ :x => true, :y => 58, :z => [1, 2, 3]}, obj)
  end

  def test_class_object
    dump_and_load(ObjectJuice, false)
  end

  def test_module_object
    dump_and_load(One, false)
  end

  def test_non_str_hash_object
    json = Oj.dump({ 1 => true, :sim => nil }, :mode => :object)
    h = Oj.load(json, :mode => :strict)
    assert_equal({"^#1" => [1, true], ":sim" => nil}, h)
    h = Oj.load(json, :mode => :object)
    assert_equal({ 1 => true, :sim => nil }, h)
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
    obj = Oj.object_load(json)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  def test_comment_c
    json = %{{
  "x"/*one*/:/*two*/true,
  "y":58,
  "z": [1,2,3]}
}
    obj = Oj.object_load(json)
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
    obj = Oj.object_load(json)
    assert_equal({ 'x' => true, 'y' => 58, 'z' => [1, 2, 3]}, obj)
  end

  def test_json_module_object
    obj = One::Two::Three::Deep.new()
    dump_and_load(obj, false)
  end

  def test_xml_time
    t = Time.new(2015, 1, 5, 21, 37, 7.123456789, -8 * 3600)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :xmlschema)
    #puts "*** json for test_xml_time '#{json}'"
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_xml_time_utc
    t = Time.utc(2015, 1, 5, 21, 37, 7.123456789)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :xmlschema)
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_ruby_time
    t = Time.new(2015, 1, 5, 21, 37, 7.123456789, -8 * 3600)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :ruby)
    #puts "*** json for test_ruby_time '#{json}'"
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_ruby_time_12345
    t = Time.new(2015, 1, 5, 21, 37, 7.123456789, 12345/60*60)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :ruby)
    #puts "*** json for test_ruby_time '#{json}'"
    loaded = Oj.object_load(json);
    #puts "*** loaded: #{loaded}"
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_ruby_time_utc
    t = Time.utc(2015, 1, 5, 21, 37, 7.123456789)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :ruby)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_time_early
    # Windows does not support dates before 1970.
    return if RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/

    t = Time.new(1954, 1, 5, 21, 37, 7.123456789, -8 * 3600)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :unix_zone)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_time_unix_zone
    t = Time.new(2015, 1, 5, 21, 37, 7.123456789, -8 * 3600)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :unix_zone)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_time_unix_zone_12345
    t = Time.new(2015, 1, 5, 21, 37, 7.123456789, 12345)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :unix_zone)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_time_unix_zone_utc
    t = Time.utc(2015, 1, 5, 21, 37, 7.123456789)
    # The fractional seconds are not always recreated exactly which causes a
    # mismatch so instead the seconds, nsecs, and gmt_offset are checked
    # separately along with utc.
    json = Oj.dump(t, :mode => :object, :time_format => :unix_zone)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(t.tv_sec, loaded.tv_sec)
    if t.respond_to?(:tv_nsec)
      assert_equal(t.tv_nsec, loaded.tv_nsec)
    else
      assert_equal(t.tv_usec, loaded.tv_usec)
    end
    assert_equal(t.utc?, loaded.utc?)
    assert_equal(t.utc_offset, loaded.utc_offset)
  end

  def test_json_object
    obj = Jeez.new(true, 58)
    dump_and_load(obj, false)
  end

  def test_json_object_create_deep
    obj = One::Two::Three::Deep.new()
    dump_and_load(obj, false)
  end

  def test_json_object_bad
    json = %{{"^o":"Junk","x":true}}
    begin
      Oj.object_load(json)
    rescue Exception => e
      assert_equal("ArgumentError", e.class().name)
      return
    end
    assert(false, "*** expected an exception")
  end

  def test_json_object_not_hat_hash
    json = %{{"^#x":[1,2]}}
    h = Oj.object_load(json)
    assert_equal({1 => 2}, h);

    json = %{{"~#x":[1,2]}}
    h = Oj.object_load(json)
    assert_equal({'~#x' => [1,2]}, h);
  end

  def test_json_struct
    obj = Stuck.new(false, 7)
    dump_and_load(obj, false)
  end

  def test_json_struct2
    obj = One::Stuck2.new(false, 7)
    dump_and_load(obj, false)
  end

  def test_json_anonymous_struct
    s = Struct.new(:x, :y)
    obj = s.new(1, 2)
    json = Oj.dump(obj, :indent => 2, :mode => :object)
    #puts json
    loaded = Oj.object_load(json);
    assert_equal(obj.members, loaded.members)
    assert_equal(obj.values, loaded.values)
  end

  def test_json_non_str_hash
    obj = { 59 => "young", false => true }
    dump_and_load(obj, false)
  end

  def test_mixed_hash_object
    Oj.default_options = { :mode => :object }
    json = Oj.dump({ 1 => true, 'nil' => nil, :sim => 4 })
    h = Oj.object_load(json)
    assert_equal({ 1 => true, 'nil' => nil, :sim => 4 }, h)
  end

  def test_json_object_object
    obj = Jeez.new(true, 58)
    json = Oj.dump(obj, :mode => :object, :indent => 2)
    assert(%{{
  "^o":"ObjectJuice::Jeez",
  "x":true,
  "y":58
}
} == json ||
%{{
  "^o":"ObjectJuice::Jeez",
  "y":58,
  "x":true
}
} == json)
    obj2 = Oj.load(json, :mode => :object)
    assert_equal(obj, obj2)
  end

  def test_to_hash_object_object
    obj = Jazz.new(true, 58)
    json = Oj.dump(obj, :mode => :object, :indent => 2)
    assert(%{{
  "^o":"ObjectJuice::Jazz",
  "x":true,
  "y":58
}
} == json ||
%{{
  "^o":"ObjectJuice::Jazz",
  "y":58,
  "x":true
}
} == json)
    obj2 = Oj.load(json, :mode => :object)
    assert_equal(obj, obj2)
  end

  def test_as_json_object_object
    obj = Orange.new(true, 58)
    json = Oj.dump(obj, :mode => :object, :indent => 2)
    assert(%{{
  "^o":"ObjectJuice::Orange",
  "x":true,
  "y":58
}
} == json ||
%{{
  "^o":"ObjectJuice::Orange",
  "y":58,
  "x":true
}
} == json)
    obj2 = Oj.load(json, :mode => :object)
    assert_equal(obj, obj2)
  end

  def test_object_object_no_cache
    obj = Jam.new(true, 58)
    json = Oj.dump(obj, :mode => :object, :indent => 2)
    assert(%{{
  "^o":"ObjectJuice::Jam",
  "x":true,
  "y":58
}
} == json ||
%{{
  "^o":"ObjectJuice::Jam",
  "y":58,
  "x":true
}
} == json)
    obj2 = Oj.load(json, :mode => :object, :class_cache => false)
    assert_equal(obj, obj2)
  end

  def test_ignore
    obj = Jeez.new(true, 58)
    json = Oj.dump({ 'a' => 7, 'b' => obj }, :mode => :object, :indent => 2, :ignore => [ Jeez ])
    assert_equal(%|{
  "a":7
}
|, json)
  end

  def test_exception
    err = nil
    begin
      raise StandardError.new('A Message')
    rescue Exception => e
      err = e
    end
    json = Oj.dump(err, :mode => :object, :indent => 2)
    #puts "*** #{json}"
    e2 = Oj.load(json, :mode => :strict)
    assert_equal(err.class.to_s, e2['^o'])
    assert_equal(err.message, e2['~mesg'])
    assert_equal(err.backtrace, e2['~bt'])
    e2 = Oj.load(json, :mode => :object)
    if 'rubinius' == $ruby
      assert_equal(e.class, e2.class);
      assert_equal(e.message, e2.message);
      assert_equal(e.backtrace, e2.backtrace);
    else
      assert_equal(e, e2);
    end
  end

  def test_range_object
    Oj.default_options = { :mode => :object }
    json = Oj.dump(1..7, :mode => :object, :indent => 0)
    if 'rubinius' == $ruby
      assert(%{{"^O":"Range","begin":1,"end":7,"exclude_end?":false}} == json)
    else
      assert_equal(%{{"^u":["Range",1,7,false]}}, json)
    end
    dump_and_load(1..7, false)
    dump_and_load(1..1, false)
    dump_and_load(1...7, false)
  end

  def test_circular_hash
    h = { 'a' => 7 }
    h['b'] = h
    json = Oj.dump(h, :mode => :object, :indent => 2, :circular => true)
    h2 = Oj.object_load(json, :circular => true)
    assert_equal(h2['b'].__id__, h2.__id__)
  end


  def test_json_object_missing_fields
    json = %{{ "^u": [ "ObjectJuice::Stuck",1]}}

    obj = Oj.load(json, mode: :object)
    assert_nil(obj['b'])
  end

  def test_circular_array
    a = [7]
    a << a
    json = Oj.dump(a, :mode => :object, :indent => 2, :circular => true)
    a2 = Oj.object_load(json, :circular => true)
    assert_equal(a2[1].__id__, a2.__id__)
  end

  def test_circular_array2
    a = [7]
    a << a
    json = Oj.dump(a, :mode => :object, :indent => 2, :circular => true)
    assert_equal(%{[
  "^i1",
  7,
  "^r1"
]
}, json)
    a2 = Oj.load(json, :mode => :object, :circular => true)
    assert_equal(a2[1].__id__, a2.__id__)
  end

  def test_circular_hash2
    h = { 'a' => 7 }
    h['b'] = h
    json = Oj.dump(h, :mode => :object, :indent => 2, :circular => true)
    ha = Oj.load(json, :mode => :strict)
    assert_equal({'^i' => 1, 'a' => 7, 'b' => '^r1'}, ha)
    Oj.load(json, :mode => :object, :circular => true)
    assert_equal(h['b'].__id__, h.__id__)
  end

  def test_circular_object
    obj = Jeez.new(nil, 58)
    obj.x = obj
    json = Oj.dump(obj, :mode => :object, :indent => 2, :circular => true)
    obj2 = Oj.object_load(json, :circular => true)
    assert_equal(obj2.x.__id__, obj2.__id__)
  end

  def test_circular_object2
    obj = Jam.new(nil, 58)
    obj.x = obj
    json = Oj.dump(obj, :mode => :object, :indent => 2, :circular => true)
    assert(%{{
  "^o":"ObjectJuice::Jam",
  "^i":1,
  "x":"^r1",
  "y":58
}
} == json ||
%{{
  "^o":"ObjectJuice::Jam",
  "^i":1,
  "y":58,
  "x":"^r1"
}
} == json)
    obj2 = Oj.load(json, :mode => :object, :circular => true)
    assert_equal(obj2.x.__id__, obj2.__id__)
  end

  def test_circular
    h = { 'a' => 7 }
    obj = Jeez.new(h, 58)
    obj.x['b'] = obj
    json = Oj.dump(obj, :mode => :object, :indent => 2, :circular => true)
    Oj.object_load(json, :circular => true)
    assert_equal(obj.x.__id__, h.__id__)
    assert_equal(h['b'].__id__, obj.__id__)
  end

  def test_circular2
    h = { 'a' => 7 }
    obj = Jam.new(h, 58)
    obj.x['b'] = obj
    json = Oj.dump(obj, :mode => :object, :indent => 2, :circular => true)
    ha = Oj.load(json, :mode => :strict)
    assert_equal({'^o' => 'ObjectJuice::Jam', '^i' => 1, 'x' => { '^i' => 2, 'a' => 7, 'b' => '^r1' }, 'y' => 58 }, ha)
    Oj.load(json, :mode => :object, :circular => true)
    assert_equal(obj.x.__id__, h.__id__)
    assert_equal(h['b'].__id__, obj.__id__)
  end

  def test_omit_nil
    jam = Jam.new({'a' => 1, 'b' => nil }, nil)

    json = Oj.dump(jam, :omit_nil => true, :mode => :object)
    assert_equal(%|{"^o":"ObjectJuice::Jam","x":{"a":1}}|, json)
  end

  def test_odd_date
    dump_and_load(Date.new(2012, 6, 19), false)
  end

  def test_odd_datetime
    dump_and_load(DateTime.new(2012, 6, 19, 13, 5, Rational(4, 3)), false)
    dump_and_load(DateTime.new(2012, 6, 19, 13, 5, Rational(7123456789, 1000000000)), false)
  end

  def test_bag
    json = %{{
  "^o":"ObjectJuice::Jem",
  "x":true,
  "y":58 }}
    obj = Oj.load(json, :mode => :object, :auto_define => true)
    assert_equal('ObjectJuice::Jem', obj.class.name)
    assert_equal(true, obj.x)
    assert_equal(58, obj.y)
  end

  def test_odd_string
    Oj.register_odd(Strung, Strung, :create, :to_s, 'safe?')
    s = Strung.new("Pete", true)
    dump_and_load(s, false)
  end

  def test_odd_date_replaced
    Oj.register_odd(Date, Date, :jd, :jd)
    json = Oj.dump(Date.new(2015, 3, 7), :mode => :object)
    assert_equal(%|{"^O":"Date","jd":2457089}|, json)
    dump_and_load(Date.new(2012, 6, 19), false)
  end

  def test_odd_raw
    Oj.register_odd_raw(Raw, Raw, :create, :to_json)
    json = Oj.dump(Raw.new(%|{"a":1}|), :mode => :object)
    assert_equal(%|{"^O":"ObjectJuice::Raw","to_json":{"a":1}}|, json)
    h = Oj.load(json, :mode => :object)
    assert_equal({'a' => 1}, h)
  end

  def test_odd_mod
    Oj.register_odd(Ichi::Ni, Ichi::Ni, :direct, :dump)
    json = Oj.dump(Ichi::Ni::San::Shi.new({'a' => 1}), :mode => :object)
    assert_equal(%|{"^O":"ObjectJuice::Ichi::Ni::San::Shi","dump":{"a":1}}|, json)
    h = Oj.load(json, :mode => :object)
    assert_equal({'a' => 1}, h)
  end

  def test_auto_string
    s = AutoStrung.new("Pete", true)
    dump_and_load(s, false)
  end

  def test_auto_array
    a = AutoArray.new([1, 'abc', nil], true)
    dump_and_load(a, false)
  end

  def test_auto_hash
    h = AutoHash.new(nil, true)
    h['a'] = 1
    h['b'] = 2
    dump_and_load(h, false)
  end

  def dump_and_load(obj, trace=false)
    json = Oj.dump(obj, :indent => 2, :mode => :object)
    puts json if trace
    loaded = Oj.object_load(json);
    if obj.nil?
      assert_nil(loaded)
    else
      assert_equal(obj, loaded)
    end
    loaded
  end

end
