# encoding: UTF-8

# The rails tests set this to true. Both Rails and the JSON gem monkey patch the
# as_json methods on several base classes. Depending on which one replaces the
# method last the behavior will be different. Oj.mimic_JSON abides by the same
# conflicting behavior and the tests reflect that.
$rails_monkey = false unless defined?($rails_monkey)

class SharedMimicTest < Minitest::Test
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

    def as_json()
      {"json_class" => self.class.to_s,"x" => @x,"y" => @y}
    end

    def self.json_create(h)
      self.new(h['x'], h['y'])
    end

  end # Jam

  def setup
    @default_options = Oj.default_options
    @time = Time.at(1400000000).utc
    @expected_time_string =
      if defined?(Rails)
        %{"2014-05-13T16:53:20.000Z"}
      else
        %{"2014-05-13 16:53:20 UTC"}
      end
  end

  def teardown
    Oj.default_options = @default_options
  end

# exception
  def test_exception
    begin
      JSON.parse("{")
      puts "Failed"
    rescue JSON::ParserError
      assert(true)
    rescue Exception
      assert(false, 'Expected a JSON::ParserError')
    end
  end

# dump
  def test_dump_string
    json = JSON.dump([1, true, nil, @time])
    if $rails_monkey
      assert_equal(%{[1,true,null,#{@expected_time_string}]}, json)
    else
      assert_equal(%{[1,true,null,{"json_class":"Time","s":1400000000,"n":0}]}, json)
    end
  end

  def test_dump_with_options
    Oj.default_options= {:indent => 2} # JSON this will not change anything
    json = JSON.dump([1, true, nil, @time])
    if $rails_monkey
      assert_equal(%{[
  1,
  true,
  null,
  #{@expected_time_string}
]
}, json)
    else
      assert_equal(%{[
  1,
  true,
  null,
  {
    "json_class":"Time",
    "s":1400000000,
    "n\":0
  }
]
}, json)
    end
  end

  def test_dump_io
    s = StringIO.new()
    json = JSON.dump([1, true, nil, @time], s)
    assert_equal(s, json)
    if $rails_monkey
      assert_equal(%{[1,true,null,#{@expected_time_string}]}, s.string)
    else
      assert_equal(%{[1,true,null,{"json_class":"Time","s":1400000000,"n":0}]}, s.string)
    end
  end
  # TBD options

  def test_dump_struct
    # anonymous Struct not supported by json so name it
    if Object.const_defined?("Struct::Abc")
      s = Struct::Abc
    else
      s = Struct.new("Abc", :a, :b, :c)
    end
    o = s.new(1, 'two', [true, false])
    json = JSON.dump(o)
    if o.respond_to?(:as_json)
      if $rails_monkey
        assert_equal(%|{"a":1,"b":"two","c":[true,false]}|, json)
      else
        assert_equal(%|{"json_class":"Struct::Abc","v":[1,"two",[true,false]]}|, json)
      end
    else
      j = '"' + o.to_s.gsub('"', '\\"') + '"'
      assert_equal(j, json)
    end
  end

# load
  def test_load_string
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON.load(json)
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
  end

  def test_load_io
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON.load(StringIO.new(json))
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
  end

  def test_load_proc
    Oj.mimic_JSON
    children = []
    json = %{{"a":1,"b":[true,false]}}
    if 'rubinius' == $ruby
      obj = JSON.load(json) {|x| children << x }
    else
      p = Proc.new {|x| children << x }
      obj = JSON.load(json, p)
    end
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
    assert([1, true, false, [true, false], { 'a' => 1, 'b' => [true, false]}] == children ||
           [true, false, [true, false], 1, { 'a' => 1, 'b' => [true, false]}] == children,
           "children don't match")
  end

  def test_parse_with_quirks_mode
    json = %{null}
    assert_equal(nil, JSON.parse(json, :quirks_mode => true))
    assert_raises(JSON::ParserError) { JSON.parse(json, :quirks_mode => false) }
    assert_raises(JSON::ParserError) { JSON.parse(json) }
  end

  def test_parse_with_empty_string
    Oj.mimic_JSON
    assert_raises(JSON::ParserError) { JSON.parse(' ') }
    assert_raises(JSON::ParserError) { JSON.parse("\t\t\n   ") }
  end

# []
  def test_bracket_load
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON[json]
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
  end

  def test_bracket_dump
    json = JSON[[1, true, nil]]
    assert_equal(%{[1,true,null]}, json)
  end

# generate
  def test_generate
    json = JSON.generate({ 'a' => 1, 'b' => [true, false]})
    assert(%{{"a":1,"b":[true,false]}} == json ||
           %{{"b":[true,false],"a":1}} == json)
  end
  def test_generate_options
    json = JSON.generate({ 'a' => 1, 'b' => [true, false]},
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

# fast_generate
  def test_fast_generate
    json = JSON.generate({ 'a' => 1, 'b' => [true, false]})
    assert(%{{"a":1,"b":[true,false]}} == json ||
           %{{"b":[true,false],"a":1}} == json)
  end

# pretty_generate
  def test_pretty_generate
    json = JSON.pretty_generate({ 'a' => 1, 'b' => [true, false]})
    assert(%{{
  "a": 1,
  "b": [
    true,
    false
  ]
}} == json ||
%{{
  "b": [
    true,
    false
  ],
  "a": 1
}} == json)
  end

# parse
  def test_parse
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON.parse(json)
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
  end
  def test_parse_sym_names
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON.parse(json, :symbolize_names => true)
    assert_equal({ :a => 1, :b => [true, false]}, obj)
  end
  def test_parse_additions
    jam = Jam.new(true, 58)
    json = Oj.dump(jam, :mode => :compat, :use_to_json => true)
    obj = JSON.parse(json)
    assert_equal(jam, obj)
    obj = JSON.parse(json, :create_additions => true)
    assert_equal(jam, obj)
    obj = JSON.parse(json, :create_additions => false)
    assert_equal({'json_class' => 'SharedMimicTest::Jam', 'x' => true, 'y' => 58}, obj)
    json.gsub!('json_class', 'kson_class')
    JSON.create_id = 'kson_class'
    obj = JSON.parse(json, :create_additions => true)
    JSON.create_id = 'json_class'
    assert_equal(jam, obj)
  end
  def test_parse_bang
    json = %{{"a":1,"b":[true,false]}}
    obj = JSON.parse!(json)
    assert_equal({ 'a' => 1, 'b' => [true, false]}, obj)
  end

# recurse_proc
  def test_recurse_proc
    children = []
    JSON.recurse_proc({ 'a' => 1, 'b' => [true, false]}) { |x| children << x }
    # JRuby 1.7.0 rb_yield() is broken and converts the [true, false] array into true
    unless 'jruby' == $ruby
      assert([1, true, false, [true, false], { 'a' => 1, 'b' => [true, false]}] == children ||
             [true, false, [true, false], 1, { 'b' => [true, false], 'a' => 1}] == children)
    end
  end

# make sure to_json is defined for object.
  def test_mimic_to_json
    {'a' => 1}.to_json()
    Object.new().to_json()
  end
end # SharedMimicTest

if defined?(ActiveSupport)
  class SharedMimicRailsTest < SharedMimicTest
    def test_activesupport_exception
      begin
        ActiveSupport::JSON.decode("{")
        puts "Failed"
      rescue ActiveSupport::JSON.parse_error
        assert(true)
      rescue Exception
        assert(false, 'Expected a JSON::ParserError')
      end
    end

    def test_activesupport_encode
      Oj.default_options= {:indent => 0}
      json = ActiveSupport::JSON.encode([1, true, nil])
      assert_equal(%{[1,true,null]}, json)
    end
  end # SharedMimicRailsTest
end
