#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)

require 'helper'

class Hashi < Minitest::Test

  module TestModule
  end

  def test_dump
    h = Oj::EasyHash.new()
    h['abc'] = 3
    out = Oj.dump(h, :mode => :compat)
    assert_equal(%|{"abc":3}|, out)
  end

  def test_load
    obj = Oj.load(%|{"abc":3}|, :mode => :compat, :hash_class => Oj::EasyHash)
    
    assert_equal(Oj::EasyHash, obj.class)
    assert_equal(3, obj['abc'])
    assert_equal(3, obj[:abc])
    assert_equal(3, obj.abc())
  end
  
end # HashTest
