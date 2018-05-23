#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), '..')

require 'helper'

class MimicRedefine < Minitest::Test
  def test_mimic_redefine
    require 'json'
    parser_error = JSON::ParserError
    Oj.mimic_JSON
    assert_equal(parser_error, JSON::ParserError)
  end
end # MimicSingle
