#!/usr/bin/env ruby
# encoding: utf-8

# frozen_string_literal: false

require 'json_gem/test_helper'

class JSONGeneratorTest < Test::Unit::TestCase
  include Test::Unit::TestCaseOmissionSupport
  include Test::Unit::TestCasePendingSupport

  def setup
    @hash = {
      'a' => 2,
      'b' => 3.141,
      'c' => 'c',
      'd' => [ 1, "b", 3.14 ],
      'e' => { 'foo' => 'bar' },
      'g' => "\"\0\037",
      'h' => 1000.0,
      'i' => 0.001
    }
    @json2 = '{"a":2,"b":3.141,"c":"c","d":[1,"b",3.14],"e":{"foo":"bar"},' +
      '"g":"\\"\\u0000\\u001f","h":1000.0,"i":0.001}'
    @json3 = <<'EOT'.chomp
{
  "a": 2,
  "b": 3.141,
  "c": "c",
  "d": [
    1,
    "b",
    3.14
  ],
  "e": {
    "foo": "bar"
  },
  "g": "\"\u0000\u001f",
  "h": 1000.0,
  "i": 0.001
}
EOT
  end

  def test_generate
    json = JSON.generate(@hash)
    assert_equal(JSON.parse(@json2), JSON.parse(json))
    json = JSON[@hash]
    assert_equal(JSON.parse(@json2), JSON.parse(json))
    parsed_json = JSON.parse(json)
    assert_equal(@hash, parsed_json)
    json = JSON.generate({1=>2})
    assert_equal('{"1":2}', json)
    parsed_json = JSON.parse(json)
    assert_equal({"1"=>2}, parsed_json)
    assert_equal '666', JSON.generate(666)
  end

  def test_generate_pretty
    json = JSON.pretty_generate(@hash)
    # hashes aren't (insertion) ordered on every ruby implementation
    assert_equal(@json3, json)
    assert_equal(JSON.parse(@json3), JSON.parse(json))
    parsed_json = JSON.parse(json)
    assert_equal(@hash, parsed_json)
    json = JSON.pretty_generate({1=>2})
    assert_equal(<<'EOT'.chomp, json)
{
  "1": 2
}
EOT
    parsed_json = JSON.parse(json)
    assert_equal({"1"=>2}, parsed_json)
    assert_equal '666', JSON.pretty_generate(666)
  end

  def test_generate_custom
    state = JSON::State.new(:space_before => " ", :space => "   ", :indent => "<i>", :object_nl => "\n", :array_nl => "<a_nl>")
    json = JSON.generate({1=>{2=>3,4=>[5,6]}}, state)
    assert_equal(<<'EOT'.chomp, json)
{
<i>"1" :   {
<i><i>"2" :   3,
<i><i>"4" :   [<a_nl><i><i><i>5,<a_nl><i><i><i>6<a_nl><i><i>]
<i>}
}
EOT
  end

  def test_fast_generate
    json = JSON.fast_generate(@hash)
    assert_equal(JSON.parse(@json2), JSON.parse(json))
    parsed_json = JSON.parse(json)
    assert_equal(@hash, parsed_json)
    json = JSON.fast_generate({1=>2})
    assert_equal('{"1":2}', json)
    parsed_json = JSON.parse(json)
    assert_equal({"1"=>2}, parsed_json)
    assert_equal '666', JSON.fast_generate(666)
  end

  def test_own_state
    state = JSON::State.new
    json = JSON.generate(@hash, state)
    assert_equal(JSON.parse(@json2), JSON.parse(json))
    parsed_json = JSON.parse(json)
    assert_equal(@hash, parsed_json)
    json = JSON.generate({1=>2}, state)
    assert_equal('{"1":2}', json)
    parsed_json = JSON.parse(json)
    assert_equal({"1"=>2}, parsed_json)
    assert_equal '666', JSON.generate(666, state)
  end

  # TBD Implement JSON.state to return state class.
  # set state attibutes from defaults
  # implement methods
  # circular should use circular in defaults or maybe always set to true, allow changes with [:check_circular]=
  def test_states
    json = JSON.generate({1=>2}, nil)
    assert_equal('{"1":2}', json)
    s = JSON.state.new
    assert s.check_circular?
    assert s[:check_circular?]
    h = { 1=>2 }
    h[3] = h
    assert_raise(JSON::NestingError) {  JSON.generate(h) }
    assert_raise(JSON::NestingError) {  JSON.generate(h, s) }
    s = JSON.state.new
    a = [ 1, 2 ]
    a << a
    assert_raise(JSON::NestingError) {  JSON.generate(a, s) }
    assert s.check_circular?
    assert s[:check_circular?]
  end

  def test_pretty_state
    state = JSON::PRETTY_STATE_PROTOTYPE.dup
    assert_equal({
      :allow_nan             => false,
      :array_nl              => "\n",
      :ascii_only            => false,
      :buffer_initial_length => 1024,
      :depth                 => 0,
      :indent                => "  ",
      :max_nesting           => 100,
      :object_nl             => "\n",
      :space                 => " ",
      :space_before          => "",
    }.sort_by { |n,| n.to_s }, state.to_h.sort_by { |n,| n.to_s })
  end

  def test_safe_state
    state = JSON::SAFE_STATE_PROTOTYPE.dup
    assert_equal({
      :allow_nan             => false,
      :array_nl              => "",
      :ascii_only            => false,
      :buffer_initial_length => 1024,
      :depth                 => 0,
      :indent                => "",
      :max_nesting           => 100,
      :object_nl             => "",
      :space                 => "",
      :space_before          => "",
    }.sort_by { |n,| n.to_s }, state.to_h.sort_by { |n,| n.to_s })
  end

  def test_fast_state
    state = JSON::FAST_STATE_PROTOTYPE.dup
    assert_equal({
      :allow_nan             => false,
      :array_nl              => "",
      :ascii_only            => false,
      :buffer_initial_length => 1024,
      :depth                 => 0,
      :indent                => "",
      :max_nesting           => 0,
      :object_nl             => "",
      :space                 => "",
      :space_before          => "",
    }.sort_by { |n,| n.to_s }, state.to_h.sort_by { |n,| n.to_s })
  end

  def test_allow_nan
    assert_raise(JSON::GeneratorError) { JSON.generate([JSON::NaN]) }
    assert_equal '[NaN]', JSON.generate([JSON::NaN], :allow_nan => true)
    assert_raise(JSON::GeneratorError) { JSON.fast_generate([JSON::NaN]) }
    assert_raise(JSON::GeneratorError) { JSON.pretty_generate([JSON::NaN]) }
    assert_equal "[\n  NaN\n]", JSON.pretty_generate([JSON::NaN], :allow_nan => true)
    assert_raise(JSON::GeneratorError) { JSON.generate([JSON::Infinity]) }
    assert_equal '[Infinity]', JSON.generate([JSON::Infinity], :allow_nan => true)
    assert_raise(JSON::GeneratorError) { JSON.fast_generate([JSON::Infinity]) }
    assert_raise(JSON::GeneratorError) { JSON.pretty_generate([JSON::Infinity]) }
    assert_equal "[\n  Infinity\n]", JSON.pretty_generate([JSON::Infinity], :allow_nan => true)
    assert_raise(JSON::GeneratorError) { JSON.generate([JSON::MinusInfinity]) }
    assert_equal '[-Infinity]', JSON.generate([JSON::MinusInfinity], :allow_nan => true)
    assert_raise(JSON::GeneratorError) { JSON.fast_generate([JSON::MinusInfinity]) }
    assert_raise(JSON::GeneratorError) { JSON.pretty_generate([JSON::MinusInfinity]) }
    assert_equal "[\n  -Infinity\n]", JSON.pretty_generate([JSON::MinusInfinity], :allow_nan => true)
  end

  def test_depth
    ary = []; ary << ary
    assert_equal 0, JSON::SAFE_STATE_PROTOTYPE.depth
    assert_raise(JSON::NestingError) { JSON.generate(ary) }
    assert_equal 0, JSON::SAFE_STATE_PROTOTYPE.depth
    assert_equal 0, JSON::PRETTY_STATE_PROTOTYPE.depth
    assert_raise(JSON::NestingError) { JSON.pretty_generate(ary) }
    assert_equal 0, JSON::PRETTY_STATE_PROTOTYPE.depth
    s = JSON.state.new
    assert_equal 0, s.depth
    assert_raise(JSON::NestingError) { ary.to_json(s) }
    assert_equal 100, s.depth
  end

  def test_buffer_initial_length
    s = JSON.state.new
    assert_equal 1024, s.buffer_initial_length
    s.buffer_initial_length = 0
    assert_equal 1024, s.buffer_initial_length
    s.buffer_initial_length = -1
    assert_equal 1024, s.buffer_initial_length
    s.buffer_initial_length = 128
    assert_equal 128, s.buffer_initial_length
  end

  def test_gc
    if respond_to?(:assert_in_out_err)
      assert_in_out_err(%w[-rjson --disable-gems], <<-EOS, [], [])
        bignum_too_long_to_embed_as_string = 1234567890123456789012345
        expect = bignum_too_long_to_embed_as_string.to_s
        GC.stress = true

        10.times do |i|
          tmp = bignum_too_long_to_embed_as_string.to_json
          raise "'\#{expect}' is expected, but '\#{tmp}'" unless tmp == expect
        end
      EOS
    end
  end if GC.respond_to?(:stress=)

  def test_configure_using_configure_and_merge
    numbered_state = {
      :indent       => "1",
      :space        => '2',
      :space_before => '3',
      :object_nl    => '4',
      :array_nl     => '5'
    }
    state1 = JSON.state.new
    state1.merge(numbered_state)
    assert_equal '1', state1.indent
    assert_equal '2', state1.space
    assert_equal '3', state1.space_before
    assert_equal '4', state1.object_nl
    assert_equal '5', state1.array_nl
    state2 = JSON.state.new
    state2.configure(numbered_state)
    assert_equal '1', state2.indent
    assert_equal '2', state2.space
    assert_equal '3', state2.space_before
    assert_equal '4', state2.object_nl
    assert_equal '5', state2.array_nl
  end

  def test_configure_hash_conversion
    state = JSON.state.new
    state.configure(:indent => '1')
    assert_equal '1', state.indent
    state = JSON.state.new
    foo = 'foo'
    assert_raise(TypeError) do
      state.configure(foo)
    end
    def foo.to_h
      { :indent => '2' }
    end
    state.configure(foo)
    assert_equal '2', state.indent
  end

  if defined?(JSON::Ext::Generator)
    def test_broken_bignum # [ruby-core:38867]
      pid = fork do
        x = 1 << 64
        x.class.class_eval do
          def to_s
          end
        end
        begin
          j = JSON::Ext::Generator::State.new.generate(x)
          exit 1
        rescue TypeError
          exit 0
        end
      end
      _, status = Process.waitpid2(pid)
      assert status.success?
    rescue NotImplementedError
      # forking to avoid modifying core class of a parent process and
      # introducing race conditions of tests are run in parallel
    end
  end

  def test_hash_likeness_set_symbol
    state = JSON.state.new
    assert_equal nil, state[:foo]
    assert_equal nil.class, state[:foo].class
    assert_equal nil, state['foo']
    state[:foo] = :bar
    assert_equal :bar, state[:foo]
    assert_equal :bar, state['foo']
    state_hash = state.to_hash
    assert_kind_of Hash, state_hash
    assert_equal :bar, state_hash[:foo]
  end

  def test_hash_likeness_set_string
    state = JSON.state.new
    assert_equal nil, state[:foo]
    assert_equal nil, state['foo']
    state['foo'] = :bar
    assert_equal :bar, state[:foo]
    assert_equal :bar, state['foo']
    state_hash = state.to_hash
    assert_kind_of Hash, state_hash
    assert_equal :bar, state_hash[:foo]
  end

  def test_json_generate
    assert_raise JSON::GeneratorError do
      assert_equal true, JSON.generate(["\xea"])
    end
  end

  def test_nesting
    too_deep = '[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["Too deep"]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]'
    too_deep_ary = eval too_deep
    assert_raise(JSON::NestingError) { JSON.generate too_deep_ary }
    assert_raise(JSON::NestingError) { JSON.generate too_deep_ary, :max_nesting => 100 }
    ok = JSON.generate too_deep_ary, :max_nesting => 101
    assert_equal too_deep, ok
    ok = JSON.generate too_deep_ary, :max_nesting => nil
    assert_equal too_deep, ok
    ok = JSON.generate too_deep_ary, :max_nesting => false
    assert_equal too_deep, ok
    ok = JSON.generate too_deep_ary, :max_nesting => 0
    assert_equal too_deep, ok
  end

  def test_backslash
    data = [ '\\.(?i:gif|jpe?g|png)$' ]
    json = '["\\\\.(?i:gif|jpe?g|png)$"]'
    assert_equal json, JSON.generate(data)
    #
    data = [ '\\"' ]
    json = '["\\\\\""]'
    assert_equal json, JSON.generate(data)
    #
    data = [ '/' ]
    json = '["/"]'
    assert_equal json, JSON.generate(data)
    #
    data = ['"']
    json = '["\""]'
    assert_equal json, JSON.generate(data)
    #
    data = ["'"]
    json = '["\\\'"]'
    assert_equal '["\'"]', JSON.generate(data)
  end

  def test_string_subclass
    s = Class.new(String) do
      def to_s; self; end
      undef to_json
    end
    assert_nothing_raised(SystemStackError) do
      assert_equal '["foo"]', JSON.generate([s.new('foo')])
    end
  end
end
