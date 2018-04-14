#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), '..')

require 'helper'
require 'isolated/shared'

Oj.mimic_JSON

class MimicAlone < SharedMimicTest
end # MimicAlone
