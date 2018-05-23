#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), '..')

require 'helper'

Oj.mimic_JSON
begin
  require 'rails/all'
rescue LoadError => e
  puts "Rails are not in the gemfile, skipping tests"
  Process.exit
end

require 'isolated/shared'

$rails_monkey = true

class MimicRailsBefore < SharedMimicRailsTest
end # MimicRailsBefore
