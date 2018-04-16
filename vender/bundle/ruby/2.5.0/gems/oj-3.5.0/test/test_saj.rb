#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'

$json = %{{
  "array": [
    {
      "num"   : 3,
      "string": "message",
      "hash"  : {
        "h2"  : {
          "a" : [ 1, 2, 3 ]
        }
      }
    }
  ],
  "boolean" : true
}}

class AllSaj < Oj::Saj
  attr_accessor :calls

  def initialize()
    @calls = []
  end

  def hash_start(key)
    @calls << [:hash_start, key]
  end

  def hash_end(key)
    @calls << [:hash_end, key]
  end

  def array_start(key)
    @calls << [:array_start, key]
  end

  def array_end(key)
    @calls << [:array_end, key]
  end

  def add_value(value, key)
    @calls << [:add_value, value, key]
  end

  def error(message, line, column)
    @calls << [:error, message, line, column]
  end

end # AllSaj

class SajTest < Minitest::Test

  def setup
    @default_options = Oj.default_options
  end

  def teardown
    Oj.default_options = @default_options
  end

  def test_nil
    handler = AllSaj.new()
    json = %{null}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, nil, nil]], handler.calls)
  end

  def test_true
    handler = AllSaj.new()
    json = %{true}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, true, nil]], handler.calls)
  end

  def test_false
    handler = AllSaj.new()
    json = %{false}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, false, nil]], handler.calls)
  end

  def test_string
    handler = AllSaj.new()
    json = %{"a string"}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, 'a string', nil]], handler.calls)
  end

  def test_fixnum
    handler = AllSaj.new()
    json = %{12345}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, 12345, nil]], handler.calls)
  end

  def test_float
    handler = AllSaj.new()
    json = %{12345.6789}
    Oj.saj_parse(handler, json)
    assert_equal([[:add_value, 12345.6789, nil]], handler.calls)
  end

  def test_float_exp
    handler = AllSaj.new()
    json = %{12345.6789e7}
    Oj.saj_parse(handler, json)
    assert_equal(1, handler.calls.size)
    assert_equal(:add_value, handler.calls[0][0])
    assert_equal((12345.6789e7 * 10000).to_i, (handler.calls[0][1] * 10000).to_i)
  end

  def test_array_empty
    handler = AllSaj.new()
    json = %{[]}
    Oj.saj_parse(handler, json)
    assert_equal([[:array_start, nil],
                  [:array_end, nil]], handler.calls)
  end

  def test_array
    handler = AllSaj.new()
    json = %{[true,false]}
    Oj.saj_parse(handler, json)
    assert_equal([[:array_start, nil],
                  [:add_value, true, nil],
                  [:add_value, false, nil],
                  [:array_end, nil]], handler.calls)
  end

  def test_hash_empty
    handler = AllSaj.new()
    json = %{{}}
    Oj.saj_parse(handler, json)
    assert_equal([[:hash_start, nil],
                  [:hash_end, nil]], handler.calls)
  end

  def test_hash
    handler = AllSaj.new()
    json = %{{"one":true,"two":false}}
    Oj.saj_parse(handler, json)
    assert_equal([[:hash_start, nil],
                  [:add_value, true, 'one'],
                  [:add_value, false, 'two'],
                  [:hash_end, nil]], handler.calls)
  end

  def test_full
    handler = AllSaj.new()
    Oj.saj_parse(handler, $json)
    assert_equal([[:hash_start, nil],
                  [:array_start, 'array'],
                  [:hash_start, nil],
                  [:add_value, 3, 'num'],
                  [:add_value, 'message', 'string'],
                  [:hash_start, 'hash'],
                  [:hash_start, 'h2'],
                  [:array_start, 'a'],
                  [:add_value, 1, nil],
                  [:add_value, 2, nil],
                  [:add_value, 3, nil],
                  [:array_end, 'a'],
                  [:hash_end, 'h2'],
                  [:hash_end, 'hash'],
                  [:hash_end, nil],
                  [:array_end, 'array'],
                  [:add_value, true, 'boolean'],
                  [:hash_end, nil]], handler.calls)
  end

  def test_fixnum_bad
    handler = AllSaj.new()
    json = %{12345xyz}
    Oj.saj_parse(handler, json)
    assert_equal([:add_value, 12345, nil], handler.calls.first)
    type, message, line, column = handler.calls.last
    assert_equal([:error, 1, 6], [type, line, column])
    assert_match(%r{invalid format, extra characters at line 1, column 6 \[(?:[a-z\.]+/)*saj\.c:\d+\]}, message)
  end

end
