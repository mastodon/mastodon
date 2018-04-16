#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)
$oj_dir = File.dirname(File.expand_path(File.dirname(__FILE__)))
%w(lib ext).each do |dir|
  $: << File.join($oj_dir, dir)
end

require 'test_compat'
require 'test_custom'
require 'test_fast'
require 'test_file'
require 'test_gc'
require 'test_hash'
require 'test_null'
require 'test_object'
require 'test_saj'
require 'test_scp'
require 'test_strict'
require 'test_various'
require 'test_wab'
require 'test_writer'
