#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'
require 'socket'
require 'stringio'

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

class NoHandler < Oj::ScHandler
  def initialize()
  end
end

class AllHandler < Oj::ScHandler
  attr_accessor :calls

  def initialize()
    @calls = []
  end

  def hash_start()
    @calls << [:hash_start]
    {}
  end

  def hash_end()
    @calls << [:hash_end]
  end

  def hash_key(key)
    @calls << [:hash_key, key]
    return 'too' if 'two' == key
    return :symbol if 'symbol' == key
    key
  end

  def array_start()
    @calls << [:array_start]
    []
  end

  def array_end()
    @calls << [:array_end]
  end

  def add_value(value)
    @calls << [:add_value, value]
  end

  def hash_set(h, key, value)
    @calls << [:hash_set, key, value]
  end

  def array_append(a, value)
    @calls << [:array_append, value]
  end

end # AllHandler

class Closer < AllHandler
  attr_accessor :io
  def initialize(io)
    super()
    @io = io
  end

  def hash_start()
    @calls << [:hash_start]
    @io.close
    {}
  end

  def hash_set(h, key, value)
    @calls << [:hash_set, key, value]
    @io.close
  end

end # Closer

class ScpTest < Minitest::Test

  def setup
    @default_options = Oj.default_options
  end

  def teardown
    Oj.default_options = @default_options
  end

  def test_nil
    handler = AllHandler.new()
    json = %{null}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, nil]], handler.calls)
  end

  def test_true
    handler = AllHandler.new()
    json = %{true}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, true]], handler.calls)
  end

  def test_false
    handler = AllHandler.new()
    json = %{false}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, false]], handler.calls)
  end

  def test_string
    handler = AllHandler.new()
    json = %{"a string"}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, 'a string']], handler.calls)
  end

  def test_fixnum
    handler = AllHandler.new()
    json = %{12345}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, 12345]], handler.calls)
  end

  def test_float
    handler = AllHandler.new()
    json = %{12345.6789}
    Oj.sc_parse(handler, json)
    assert_equal([[:add_value, 12345.6789]], handler.calls)
  end

  def test_float_exp
    handler = AllHandler.new()
    json = %{12345.6789e7}
    Oj.sc_parse(handler, json)
    assert_equal(1, handler.calls.size)
    assert_equal(:add_value, handler.calls[0][0])
    assert_equal((12345.6789e7 * 10000).to_i, (handler.calls[0][1] * 10000).to_i)
  end

  def test_array_empty
    handler = AllHandler.new()
    json = %{[]}
    Oj.sc_parse(handler, json)
    assert_equal([[:array_start],
                  [:array_end],
                  [:add_value, []]], handler.calls)
  end

  def test_array
    handler = AllHandler.new()
    json = %{[true,false]}
    Oj.sc_parse(handler, json)
    assert_equal([[:array_start],
                  [:array_append, true],
                  [:array_append, false],
                  [:array_end],
                  [:add_value, []]], handler.calls)
  end

  def test_hash_empty
    handler = AllHandler.new()
    json = %{{}}
    Oj.sc_parse(handler, json)
    assert_equal([[:hash_start],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_hash
    handler = AllHandler.new()
    json = %{{"one":true,"two":false}}
    Oj.sc_parse(handler, json)
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true],
                  [:hash_key, 'two'],
                  [:hash_set, 'too', false],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_hash_sym
    handler = AllHandler.new()
    json = %{{"one":true,"two":false}}
    Oj.sc_parse(handler, json, :symbol_keys => true)
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true],
                  [:hash_key, 'two'],
                  [:hash_set, 'too', false],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_symbol_hash_key_without_symbol_keys
    handler = AllHandler.new()
    json = %{{"one":true,"symbol":false}}
    Oj.sc_parse(handler, json)
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true],
                  [:hash_key, 'symbol'],
                  [:hash_set, :symbol, false],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_full
    handler = AllHandler.new()
    Oj.sc_parse(handler, $json)
    assert_equal([[:hash_start],
                  [:hash_key, 'array'],
                  [:array_start],
                  [:hash_start],
                  [:hash_key, 'num'],
                  [:hash_set, "num", 3],
                  [:hash_key, 'string'],
                  [:hash_set, "string", "message"],
                  [:hash_key, 'hash'],
                  [:hash_start],
                  [:hash_key, 'h2'],
                  [:hash_start],
                  [:hash_key, 'a'],
                  [:array_start],
                  [:array_append, 1],
                  [:array_append, 2],
                  [:array_append, 3],
                  [:array_end],
                  [:hash_set, "a", []],
                  [:hash_end],
                  [:hash_set, "h2", {}],
                  [:hash_end],
                  [:hash_set, "hash", {}],
                  [:hash_end],
                  [:array_append, {}],
                  [:array_end],
                  [:hash_set, "array", []],
                  [:hash_key, 'boolean'],
                  [:hash_set, "boolean", true],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_double
    handler = AllHandler.new()
    json = %{{"one":true,"two":false}{"three":true,"four":false}}
    Oj.sc_parse(handler, json)
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true],
                  [:hash_key, 'two'],
                  [:hash_set, 'too', false],
                  [:hash_end],
                  [:add_value, {}],
                  [:hash_start],
                  [:hash_key, 'three'],
                  [:hash_set, 'three', true],
                  [:hash_key, 'four'],
                  [:hash_set, 'four', false],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_double_io
    handler = AllHandler.new()
    json = %{{"one":true,"two":false}{"three":true,"four":false}}
    Oj.sc_parse(handler, StringIO.new(json))
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true],
                  [:hash_key, 'two'],
                  [:hash_set, 'too', false],
                  [:hash_end],
                  [:add_value, {}],
                  [:hash_start],
                  [:hash_key, 'three'],
                  [:hash_set, 'three', true],
                  [:hash_key, 'four'],
                  [:hash_set, 'four', false],
                  [:hash_end],
                  [:add_value, {}]], handler.calls)
  end

  def test_none
    handler = NoHandler.new()
    Oj.sc_parse(handler, $json)
  end

  def test_fixnum_bad
    handler = AllHandler.new()
    json = %{12345xyz}
    assert_raises Oj::ParseError do
      Oj.sc_parse(handler, json)
    end
  end

  def test_null_string
    handler = AllHandler.new()
    json = %{"\0"}
    assert_raises Oj::ParseError do
      Oj.sc_parse(handler, json)
    end
  end

  def test_pipe
    # Windows does not support fork
    return if RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/

    handler = AllHandler.new()
    json = %{{"one":true,"two":false}}
    IO.pipe do |read_io, write_io|
      if fork
        write_io.close
        Oj.sc_parse(handler, read_io) {|v| p v}
        read_io.close
        assert_equal([[:hash_start],
                      [:hash_key, 'one'],
                      [:hash_set, 'one', true],
                      [:hash_key, 'two'],
                      [:hash_set, 'too', false],
                      [:hash_end],
                      [:add_value, {}]], handler.calls)
      else
        read_io.close
        write_io.write json
        write_io.close
        Process.exit(0)
      end
    end
  end

  def test_pipe_close
    # Windows does not support fork
    return if RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/

    json = %{{"one":true,"two":false}}
    IO.pipe do |read_io, write_io|
      if fork
        write_io.close
        handler = Closer.new(read_io)
        err = nil
        begin
          Oj.sc_parse(handler, read_io)
          read_io.close
        rescue Exception => e
          err = e.class.to_s
        end
        assert_equal("IOError", err)
        assert_equal([[:hash_start],
                      [:hash_key, 'one'],
                      [:hash_set, 'one', true]], handler.calls)
      else
        read_io.close
        write_io.write json[0..11]
        sleep(0.1)
        begin
          write_io.write json[12..-1]
        rescue Exception => e
          # ignore, should fail to write
        end
        write_io.close
        Process.exit(0)
      end
    end
  end

  def test_socket_close
    json = %{{"one":true,"two":false}}
    begin
      server = TCPServer.new(8080)
    rescue
      # Not able to open a socket to run the test. Might be Travis.
      return
    end
    Thread.start(json) do |j|
      c = server.accept()
      c.puts json[0..11]
      10.times {
        break if c.closed?
        sleep(0.1)
      }
      unless c.closed?
        c.puts json[12..-1]
        c.close
      end
    end
    begin
      sock = TCPSocket.new('localhost', 8080)
    rescue
      # Not able to open a socket to run the test. Might be Travis.
      return
    end
    handler = Closer.new(sock)
    err = nil
    begin
      Oj.sc_parse(handler, sock)
    rescue Exception => e
      err = e.class.to_s
    end
    assert_equal("IOError", err)
    assert_equal([[:hash_start],
                  [:hash_key, 'one'],
                  [:hash_set, 'one', true]], handler.calls)
  end

end
