#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'
require 'oj'

class ObjectFolder < Minitest::Test
  class Raccoon
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def as_json(options={})
      {:name => @name}.merge(options)
    end
  end

  def setup
    @default_options = Oj.default_options
  end

  def teardown
    Oj.default_options = @default_options
  end

  def test_as_json_options
    Oj.mimic_JSON()
    raccoon = Raccoon.new('Rocket')
    json = raccoon.to_json()
    assert_equal(json, '{"name":"Rocket"}')

    json = raccoon.to_json(:occupation => 'bounty hunter')
    # depending on the ruby version the order of the hash members maybe different.
    if (json.start_with?('{"name'))
        assert_equal(json, '{"name":"Rocket","occupation":"bounty hunter"}')
    else
        assert_equal(json, '{"occupation":"bounty hunter","name":"Rocket"}')
    end
  end

end
