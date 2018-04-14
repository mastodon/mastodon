#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'optparse'
require 'yajl'
require 'perf'
require 'json'
require 'json/ext'
require 'oj'

$verbose = false
$indent = 0
$iter = 10000
$gets = 0
$fetch = false
$write = false
$read = false

opts = OptionParser.new
opts.on("-v", "verbose")                                  { $verbose = true }
opts.on("-c", "--count [Int]", Integer, "iterations")     { |i| $iter = i }
opts.on("-i", "--indent [Int]", Integer, "indentation")   { |i| $indent = i }
opts.on("-g", "--gets [Int]", Integer, "number of gets")  { |i| $gets = i }
opts.on("-f", "fetch")                                    { $fetch = true }
opts.on("-w", "write")                                    { $write = true }
opts.on("-r", "read")                                     { $read = true }
opts.on("-h", "--help", "Show this display")              { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

class AllSaj < Oj::Saj
  def initialize()
  end

  def hash_start(key)
  end

  def hash_end(key)
  end

  def array_start(key)
  end

  def array_end(key)
  end

  def add_value(value, key)
  end
end # AllSaj

class NoSaj < Oj::Saj
  def initialize()
  end
end # NoSaj

saj_handler = AllSaj.new()
no_saj = NoSaj.new()

$obj = {
  'a' => 'Alpha', # string
  'b' => true,    # boolean
  'c' => 12345,   # number
  'd' => [ true, [false, {'12345' => 12345, 'nil' => nil}, 3.967, { 'x' => 'something', 'y' => false, 'z' => true}, nil]], # mix it up array
  'e' => { 'one' => 1, 'two' => 2 }, # hash
  'f' => nil,     # nil
  'g' => 12345678901234567890123456789, # big number
  'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
  'i' => [[[[[[[nil]]]]]]]  # deep array, again, not that deep
}

Oj.default_options = { :indent => $indent, :mode => :compat }

$json = Oj.dump($obj)
$failed = {} # key is same as String used in tests later

def capture_error(tag, orig, load_key, dump_key, &blk)
  begin
    obj = blk.call(orig)
    raise "#{tag} #{dump_key} and #{load_key} did not return the same object as the original." unless orig == obj
  rescue Exception => e
    $failed[tag] = "#{e.class}: #{e.message}"
  end
end

# Verify that all packages dump and load correctly and return the same Object as the original.
capture_error('Yajl', $obj, 'encode', 'parse') { |o| Yajl::Parser.parse(Yajl::Encoder.encode(o)) }
capture_error('JSON::Ext', $obj, 'generate', 'parse') { |o| JSON.generator = JSON::Ext::Generator; JSON::Ext::Parser.new(JSON.generate(o)).parse }

if $verbose
  puts "json:\n#{$json}\n"
end


puts '-' * 80
puts "Parse Performance"
perf = Perf.new()
perf.add('Oj::Saj', 'all') { Oj.saj_parse(saj_handler, $json) }
perf.add('Oj::Saj', 'none') { Oj.saj_parse(no_saj, $json) }
perf.add('Yajl', 'parse') { Yajl::Parser.parse($json) } unless $failed.has_key?('Yajl')
perf.add('JSON::Ext', 'parse') { JSON::Ext::Parser.new($json).parse } unless $failed.has_key?('JSON::Ext')
perf.run($iter)

unless $failed.empty?
  puts "The following packages were not included for the reason listed"
  $failed.each { |tag,msg| puts "***** #{tag}: #{msg}" }
end
