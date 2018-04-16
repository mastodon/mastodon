#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), '..')

require 'helper'

begin
  require 'rails/all'
rescue LoadError => e
  puts "Rails are not in the gemfile, skipping tests"
  Process.exit
end

Oj.mimic_JSON

require 'isolated/shared'

$rails_monkey = true

class MimicRailsAfter < SharedMimicRailsTest
end # MimicRailsAfter
