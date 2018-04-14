#!/usr/bin/env ruby
# encoding: UTF-8

#frozen_string_literal: false

require 'json_gem/test_helper'

class JSONGenericObjectTest < Test::Unit::TestCase
  include Test::Unit::TestCaseOmissionSupport

  def setup
    @go = JSON::GenericObject[ :a => 1, :b => 2 ]
  end

  def test_attributes
    assert_equal 1, @go.a
    assert_equal 1, @go[:a]
    assert_equal 2, @go.b
    assert_equal 2, @go[:b]
    assert_nil @go.c
    assert_nil @go[:c]
  end 

  def test_generate_json
    switch_json_creatable do
      assert_equal @go, JSON(JSON(@go), :create_additions => true)
    end
  end

  def test_parse_json
    x = JSON(
        '{ "json_class": "JSON::GenericObject", "a": 1, "b": 2 }',
        :create_additions => true
             )
    assert_kind_of Hash,
      JSON(
        '{ "json_class": "JSON::GenericObject", "a": 1, "b": 2 }',
        :create_additions => true
      )
    switch_json_creatable do
      assert_equal @go, l =
        JSON(
          '{ "json_class": "JSON::GenericObject", "a": 1, "b": 2 }',
             :create_additions => true
        )
      assert_equal 1, l.a
      assert_equal @go,
        l = JSON('{ "a": 1, "b": 2 }', :object_class => JSON::GenericObject)
      assert_equal 1, l.a
      assert_equal JSON::GenericObject[:a => JSON::GenericObject[:b => 2]],
        l = JSON('{ "a": { "b": 2 } }', :object_class => JSON::GenericObject)
      assert_equal 2, l.a.b
    end
  end

  def test_from_hash
    result  = JSON::GenericObject.from_hash(
      :foo => { :bar => { :baz => true }, :quux => [ { :foobar => true } ] })
    assert_kind_of JSON::GenericObject, result.foo
    assert_kind_of JSON::GenericObject, result.foo.bar
    assert_equal   true, result.foo.bar.baz
    assert_kind_of JSON::GenericObject, result.foo.quux.first
    assert_equal   true, result.foo.quux.first.foobar
    assert_equal   true, JSON::GenericObject.from_hash(true)
  end

  def test_json_generic_object_load
    empty = JSON::GenericObject.load(nil)
    assert_kind_of JSON::GenericObject, empty
    simple_json = '{"json_class":"JSON::GenericObject","hello":"world"}'
    simple = JSON::GenericObject.load(simple_json)
    assert_kind_of JSON::GenericObject, simple
    assert_equal "world", simple.hello
    converting = JSON::GenericObject.load('{ "hello": "world" }')
    assert_kind_of JSON::GenericObject, converting
    assert_equal "world", converting.hello

    json = JSON::GenericObject.dump(JSON::GenericObject[:hello => 'world'])
    assert_equal JSON(json), JSON('{"json_class":"JSON::GenericObject","hello":"world"}')
  end

  private

  def switch_json_creatable
    JSON::GenericObject.json_creatable = true
    yield
  ensure
    JSON::GenericObject.json_creatable = false
  end
end
