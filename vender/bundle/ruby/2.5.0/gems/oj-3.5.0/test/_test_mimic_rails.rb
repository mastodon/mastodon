#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'
#Oj.mimic_JSON
require 'rails/all'

require 'active_model'
require 'active_model_serializers'
require 'active_support/json'
require 'active_support/time'
require 'active_support/all'

require 'oj/active_support_helper'

Oj.mimic_JSON

class Category
  include ActiveModel::Model
  include ActiveModel::SerializerSupport

  attr_accessor :id, :name

  def initialize(id, name)
    @id   = id
    @name = name
  end
end

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name
end

class MimicRails < Minitest::Test

  def test_mimic_exception
    begin
      ActiveSupport::JSON.decode("{")
      puts "Failed"
    rescue ActiveSupport::JSON.parse_error
      assert(true)
    rescue Exception
      assert(false, 'Expected a JSON::ParserError')
    end
  end

  def test_dump_string
    Oj.default_options= {:indent => 2}
    json = ActiveSupport::JSON.encode([1, true, nil])
    assert_equal(%{[
  1,
  true,
  null
]
}, json)
  end

  def test_dump_rational
    Oj.default_options= {:indent => 2}
    json = ActiveSupport::JSON.encode([1, true, Rational(1)])
    assert_equal(%{[
  1,
  true,
  "1/1"
]
}, json)
  end

  def test_dump_range
    Oj.default_options= {:indent => 2}
    json = ActiveSupport::JSON.encode([1, true, '01'..'12'])
    assert_equal(%{[
  1,
  true,
  "01..12"
]
}, json)
  end

  def test_dump_object
    Oj.default_options= {:indent => 2}
    category = Category.new(1, 'test')
    serializer = CategorySerializer.new(category)

    json = serializer.to_json()
    puts "*** serializer.to_json() #{serializer.to_json()}"
    json = serializer.as_json()
    puts "*** serializer.as_json() #{serializer.as_json()}"
    json = JSON.dump(serializer)
    puts "*** JSON.dump(serializer) #{JSON.dump(serializer)}"

    puts "*** category.to_json() #{category.to_json()}"
    puts "*** category.as_json() #{category.as_json()}"
    puts "*** JSON.dump(serializer) #{JSON.dump(category)}"
    puts "*** Oj.dump(serializer) #{Oj.dump(category)}"

  end

  def test_dump_object_array
    Oj.default_options= {:indent => 2}
    cat1 = Category.new(1, 'test')
    cat2 = Category.new(2, 'test')
    a = Array.wrap([cat1, cat2])

    #serializer = CategorySerializer.new(a)

    puts "*** a.to_json() #{a.to_json()}"
    puts "*** a.as_json() #{a.as_json()}"
    puts "*** JSON.dump(a) #{JSON.dump(a)}"
    puts "*** Oj.dump(a) #{Oj.dump(a)}"
  end

  def test_dump_time
    Oj.default_options= {:indent => 2}
    now = ActiveSupport::TimeZone['America/Chicago'].parse("2014-11-01 13:20:47")
    json = Oj.dump(now, mode: :object, time_format: :xmlschema)
    #puts "*** json: #{json}"

    oj_dump = Oj.load(json, mode: :object, time_format: :xmlschema)
    #puts "Now: #{now}\n Oj: #{oj_dump}"
    assert_equal("2014-11-01T13:20:47-05:00", oj_dump.xmlschema)
  end

end # MimicRails
