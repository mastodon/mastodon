#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'

class DocTest < Minitest::Test
  def setup
    @default_options = Oj.default_options
    @json1 = %|{
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
    }|
  end

  def teardown
    Oj.default_options = @default_options
  end

  def test_nil
    json = %{null}
    Oj::Doc.open(json) do |doc|
      assert_equal(NilClass, doc.type)
      assert_nil(doc.fetch())
    end
  end

  def test_true
    json = %{true}
    Oj::Doc.open(json) do |doc|
      assert_equal(TrueClass, doc.type)
      assert_equal(true, doc.fetch())
    end
  end

  def test_false
    json = %{false}
    Oj::Doc.open(json) do |doc|
      assert_equal(FalseClass, doc.type)
      assert_equal(false, doc.fetch())
    end
  end

  def test_string
    json = %{"a string"}
    Oj::Doc.open(json) do |doc|
      assert_equal(String, doc.type)
      assert_equal('a string', doc.fetch())
    end
  end

  def test_encoding
    json = %{"ぴーたー"}
    Oj::Doc.open(json) do |doc|
      assert_equal(String, doc.type)
      assert_equal("ぴーたー", doc.fetch())
    end
  end

  def test_encoding_escaped
    json = %{"\\u3074\\u30fc\\u305f\\u30fc"}
    Oj::Doc.open(json) do |doc|
      assert_equal(String, doc.type)
      assert_equal("ぴーたー", doc.fetch())
    end
  end

  def test_fixnum
    json = %{12345}
    Oj::Doc.open(json) do |doc|
      if '2.4.0' <= RUBY_VERSION
        assert_equal(Integer, doc.type)
      else
        assert_equal(Fixnum, doc.type)
      end
      assert_equal(12345, doc.fetch())
    end
  end

  def test_float
    json = %{12345.6789}
    Oj::Doc.open(json) do |doc|
      assert_equal(Float, doc.type)
      assert_equal(12345.6789, doc.fetch())
    end
  end

  def test_float_exp
    json = %{12345.6789e7}
    Oj::Doc.open(json) do |doc|
      assert_equal(Float, doc.type)
      #assert_equal(12345.6789e7, doc.fetch())
      assert_equal(12345.6789e7.to_i, doc.fetch().to_i)
    end
  end

  def test_array_empty
    json = %{[]}
    Oj::Doc.open(json) do |doc|
      assert_equal(Array, doc.type)
      assert_equal([], doc.fetch())
    end
  end

  def test_array
    json = %{[true,false]}
    Oj::Doc.open(json) do |doc|
      assert_equal(Array, doc.type)
      assert_equal([true, false], doc.fetch())
    end
  end

  def test_hash_empty
    json = %{{}}
    Oj::Doc.open(json) do |doc|
      assert_equal(Hash, doc.type)
      assert_equal({}, doc.fetch())
    end
  end

  def test_hash
    json = %{{"one":true,"two":false}}
    Oj::Doc.open(json) do |doc|
      assert_equal(Hash, doc.type)
      assert_equal({'one' => true, 'two' => false}, doc.fetch())
    end
  end

  # move() and where?()
  def test_move_hash
    json = %{{"one":{"two":false}}}
    Oj::Doc.open(json) do |doc|
      doc.move('/one')
      assert_equal('/one', doc.where?)
      doc.move('/one/two')
      assert_equal('/one/two', doc.where?)
    end
  end

  def test_move_array
    json = %{[1,[2,true]]}
    Oj::Doc.open(json) do |doc|
      doc.move('/1')
      assert_equal('/1', doc.where?)
      doc.move('/2/1')
      assert_equal('/2/1', doc.where?)
    end
  end

  def test_move
    Oj::Doc.open(@json1) do |doc|
      [ '/',
        '/array',
        '/boolean',
        '/array/1/hash/h2/a/3',
      ].each do |p|
        doc.move(p)
        assert_equal(p, doc.where?)
      end
      begin
        doc.move('/array/x')
      rescue Exception
        assert_equal('/', doc.where?)
        assert(true)
      end
    end
  end

  def test_move_slash
    Oj::Doc.open(%|{"top":{"a/b":3}}|) do |doc|
      doc.move('top/a\/b')
      assert_equal('/top/a\/b', doc.where?)
    end
  end

  def test_fetch_slash
    Oj::Doc.open(%|{"a/b":3}|) do |doc|
      x = doc.fetch('a\/b')
      assert_equal(3, x)
    end
  end

  def test_move_relative
    Oj::Doc.open(@json1) do |doc|
      [['/', 'array', '/array'],
       ['/array', '1/num', '/array/1/num'],
       ['/array/1/hash', 'h2/a', '/array/1/hash/h2/a'],
       ['/array/1', 'hash/h2/a/2', '/array/1/hash/h2/a/2'],
       ['/array/1/hash', '../string', '/array/1/string'],
       ['/array/1/hash', '..', '/array/1'],
      ].each do |start,path,where|
        doc.move(start)
        doc.move(path)
        assert_equal(where, doc.where?)
      end
    end
  end

  def test_type
    if '2.4.0' <= RUBY_VERSION
      num_class = Integer
    else
      num_class = Fixnum
    end
    Oj::Doc.open(@json1) do |doc|
      [['/', Hash],
       ['/array', Array],
       ['/array/1', Hash],
       ['/array/1/num', num_class],
       ['/array/1/string', String],
       ['/array/1/hash/h2/a', Array],
       ['/array/1/hash/../num', num_class],
       ['/array/1/hash/../..', Array],
      ].each do |path,type|
        assert_equal(type, doc.type(path))
      end
    end
  end

  def test_local_key
    Oj::Doc.open(@json1) do |doc|
      [['/', nil],
       ['/array', 'array'],
       ['/array/1', 1],
       ['/array/1/num', 'num'],
       ['/array/1/string', 'string'],
       ['/array/1/hash/h2/a', 'a'],
       ['/array/1/hash/../num', 'num'],
       ['/array/1/hash/..', 1],
       ['/array/1/hash/../..', 'array'],
      ].each do |path,key|
        doc.move(path)
        if key.nil?
          assert_nil(doc.local_key())
        else
          assert_equal(key, doc.local_key())
        end
      end
    end
  end

  def test_fetch_move
    Oj::Doc.open(@json1) do |doc|
      [['/array/1/num', 3],
       ['/array/1/string', 'message'],
       ['/array/1/hash/h2/a', [1, 2, 3]],
       ['/array/1/hash/../num', 3],
       ['/array/1/hash/..', {'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}],
       ['/array/1/hash/../..', [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}]],
       ['/array/1', {'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}],
       ['/array', [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}]],
       ['/', {'array' => [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}], 'boolean' => true}],
      ].each do |path,val|
        doc.move(path)
        assert_equal(val, doc.fetch())
      end
    end
  end

  def test_fetch_path
    Oj::Doc.open(@json1) do |doc|
      [['/array/1/num', 3],
       ['/array/1/string', 'message'],
       ['/array/1/hash/h2/a', [1, 2, 3]],
       ['/array/1/hash/../num', 3],
       ['/array/1/hash/..', {'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}],
       ['/array/1/hash/../..', [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}]],
       ['/array/1', {'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}],
       ['/array', [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}]],
       ['/', {'array' => [{'num' => 3, 'string' => 'message', 'hash' => {'h2' => {'a' => [1, 2, 3]}}}], 'boolean' => true}],
      ].each do |path,val|
        assert_equal(val, doc.fetch(path))
      end
    end
  end

  def test_move_fetch_path
    Oj::Doc.open(@json1) do |doc|
      [['/array/1', 'num', 3],
       ['/array/1', 'string', 'message'],
       ['/array/1/hash', 'h2/a', [1, 2, 3]],
      ].each do |path,fetch_path,val|
        doc.move(path)
        assert_equal(val, doc.fetch(fetch_path))
      end
    end
  end

  def test_home
    Oj::Doc.open(@json1) do |doc|
      doc.move('/array/1/num')
      doc.home()
      assert_equal('/', doc.where?)
    end
  end

  def test_each_value_root
    Oj::Doc.open(@json1) do |doc|
      values = []
      doc.each_value() { |v| values << v.to_s }
      assert_equal(['1', '2', '3', '3', 'message', 'true'], values.sort)
    end
  end

  def test_each_value_move
    Oj::Doc.open(@json1) do |doc|
      doc.move('/array/1/hash')
      values = []
      doc.each_value() { |v| values << v.to_s }
      assert_equal(['1', '2', '3'], values.sort)
    end
  end

  def test_each_value_path
    Oj::Doc.open(@json1) do |doc|
      values = []
      doc.each_value('/array/1/hash') { |v| values << v.to_s }
      assert_equal(['1', '2', '3'], values.sort)
    end
  end

  def test_each_child_move
    Oj::Doc.open(@json1) do |doc|
      locations = []
      doc.move('/array/1/hash/h2/a')
      doc.each_child() { |d| locations << d.where? }
      assert_equal(['/array/1/hash/h2/a/1', '/array/1/hash/h2/a/2', '/array/1/hash/h2/a/3'], locations)
      locations = []
      doc.move('/array/1')
      doc.each_child() { |d| locations << d.where? }
      assert_equal(['/array/1/num', '/array/1/string', '/array/1/hash'], locations)
    end
  end

  def test_each_child_path
    Oj::Doc.open(@json1) do |doc|
      locations = []
      doc.each_child('/array/1/hash/h2/a') { |d| locations << d.where? }
      assert_equal(['/array/1/hash/h2/a/1', '/array/1/hash/h2/a/2', '/array/1/hash/h2/a/3'], locations)
      locations = []
      doc.each_child('/array/1') { |d| locations << d.where? }
      assert_equal(['/array/1/num', '/array/1/string', '/array/1/hash'], locations)
    end
  end

  def test_size
    Oj::Doc.open('[1,2,3]') do |doc|
      assert_equal(4, doc.size)
    end
    Oj::Doc.open('{"a":[1,2,3]}') do |doc|
      assert_equal(5, doc.size)
    end
  end

  def test_open_file
    filename = File.join(File.dirname(__FILE__), 'open_file_test.json')
    File.open(filename, 'w') { |f| f.write('{"a":[1,2,3]}') }
    Oj::Doc.open_file(filename) do |doc|
      assert_equal(5, doc.size)
    end
  end

  def test_open_close
    json = %{{"a":[1,2,3]}}
    doc = Oj::Doc.open(json)
    assert_equal(Oj::Doc, doc.class)
    assert_equal(5, doc.size)
    assert_equal('/', doc.where?)
    doc.move('a/1')
    doc.home()
    assert_equal(2, doc.fetch('/a/2'))
    assert_equal(2, doc.fetch('a/2'))
    doc.close()
    begin
      doc.home()
    rescue Exception
      assert(true)
    end
  end

  def test_file_open_close
    filename = File.join(File.dirname(__FILE__), 'open_file_test.json')
    File.open(filename, 'w') { |f| f.write('{"a":[1,2,3]}') }
    doc = Oj::Doc.open_file(filename)
    assert_equal(Oj::Doc, doc.class)
    assert_equal(5, doc.size)
    assert_equal('/', doc.where?)
    doc.move('a/1')
    doc.home()
    assert_equal(2, doc.fetch('/a/2'))
    assert_equal(2, doc.fetch('a/2'))
    doc.close()
    begin
      doc.home()
    rescue Exception
      assert(true)
    end
  end

  def test_open_no_close
    json = %{{"a":[1,2,3]}}
    doc = Oj::Doc.open(json)
    assert_equal(Oj::Doc, doc.class)
    assert_equal(5, doc.size)
    assert_equal('/', doc.where?)
    doc.move('a/1')
    doc.home()
    assert_equal(2, doc.fetch('/a/2'))
    assert_equal(2, doc.fetch('a/2'))
    doc = nil
    GC.start
    # a print statement confirms close is called
  end

  def test_dump
    Oj::Doc.open('[1,[2,3]]') do |doc|
      assert_equal('[1,[2,3]]', doc.dump())
    end
    Oj::Doc.open('[1,[2,3]]') do |doc|
      assert_equal('[2,3]', doc.dump('/2'))
    end
  end

  def test_each_leaf
    results = Oj::Doc.open('[1,[2,3]]') do |doc|
      h = {}
      doc.each_leaf() { |d| h[d.where?] = d.fetch() }
      h
    end
    assert_equal({'/1' => 1, '/2/1' => 2, '/2/2' => 3}, results)
  end

  def test_each_leaf_hash
    results = Oj::Doc.open('{"a":{"x":2},"b":{"y":4}}') do |doc|
      h = {}
      doc.each_leaf() { |d| h[d.where?] = d.fetch() }
      h
    end
    assert_equal({'/a/x' => 2, '/b/y' => 4}, results)
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
    results = Oj::Doc.open(json) do |doc|
      h = {}
      doc.each_leaf() { |d| h[d.where?] = d.fetch() }
      h
    end
    assert_equal({'/x' => true, '/y' => 58, '/z/1' => 1, '/z/2' => 2, '/z/3' => 3}, results)
  end

end # DocTest
