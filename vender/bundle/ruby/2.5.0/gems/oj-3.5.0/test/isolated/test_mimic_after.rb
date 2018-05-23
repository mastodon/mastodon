#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), '..')

require 'helper'
require 'isolated/shared'

require 'json'
Oj.mimic_JSON

class MimicAfter < SharedMimicTest
end # MimicAfter
