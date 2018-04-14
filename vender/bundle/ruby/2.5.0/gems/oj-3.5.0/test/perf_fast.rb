#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'optparse'
#require 'yajl'
require 'perf'
require 'json'
require 'json/ext'
require 'oj'

$verbose = false
$indent = 0
$iter = 100000
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

# This just navigates to each leaf of the JSON structure.
def dig(obj, &blk)
  case obj
  when Array
    obj.each { |e| dig(e, &blk) }
  when Hash
    obj.values.each { |e| dig(e, &blk) }
  else
    blk.yield(obj)
  end
end

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
capture_error('Oj::Doc', $obj, 'load', 'dump') { |o| Oj::Doc.open(Oj.dump(o, :mode => :strict)) { |f| f.fetch() } }
#capture_error('Yajl', $obj, 'encode', 'parse') { |o| Yajl::Parser.parse(Yajl::Encoder.encode(o)) }
capture_error('JSON::Ext', $obj, 'generate', 'parse') { |o| JSON.generator = JSON::Ext::Generator; JSON::Ext::Parser.new(JSON.generate(o)).parse }

if $verbose
  puts "json:\n#{$json}\n"
end

puts '-' * 80
puts "Parse Performance"
perf = Perf.new()
perf.add('Oj::Doc', 'parse') { Oj::Doc.open($json) {|f| } } unless $failed.has_key?('Oj::Doc')
#perf.add('Yajl', 'parse') { Yajl::Parser.parse($json) } unless $failed.has_key?('Yajl')
perf.add('JSON::Ext', 'parse') { JSON::Ext::Parser.new($json).parse } unless $failed.has_key?('JSON::Ext')
perf.run($iter)

puts '-' * 80
puts "JSON generation Performance"
Oj::Doc.open($json) do |doc|
  perf = Perf.new()
  perf.add('Oj::Doc', 'dump') { doc.dump() }
#  perf.add('Yajl', 'encode') { Yajl::Encoder.encode($obj) }
  perf.add('JSON::Ext', 'fast_generate') { JSON.fast_generate($obj) }
  perf.before('JSON::Ext') { JSON.generator = JSON::Ext::Generator }
  perf.run($iter)
end

if 0 < $gets
  puts '-' * 80
  puts "Parse and get all values Performance"
  perf = Perf.new()
  perf.add('Oj::Doc', 'parse') { Oj::Doc.open($json) {|f| $gets.times { f.each_value() {} } } } unless $failed.has_key?('Oj::Doc')
#  perf.add('Yajl', 'parse') { $gets.times { dig(Yajl::Parser.parse($json)) {} } } unless $failed.has_key?('Yajl')
  perf.add('JSON::Ext', 'parse') { $gets.times { dig(JSON::Ext::Parser.new($json).parse) {} } } unless $failed.has_key?('JSON::Ext')
  perf.run($iter)
end

if $fetch
  puts '-' * 80
  puts "fetch nested Performance"
  json_hash = Oj.load($json, :mode => :strict)
  Oj::Doc.open($json) do |fast|
    #puts "*** C fetch: #{fast.fetch('/d/2/4/y')}"
    #puts "*** Ruby fetch: #{json_hash.fetch('d', []).fetch(1, []).fetch(3, []).fetch('x', nil)}"
    perf = Perf.new()
    perf.add('Oj::Doc', 'fetch') { fast.fetch('/d/2/4/x'); fast.fetch('/h/a/b/c/d/e/f/g'); fast.fetch('/i/1/1/1/1/1/1/1') }
    # version that fails gracefully
    perf.add('Ruby', 'fetch') do
      json_hash.fetch('d', []).fetch(1, []).fetch(3, []).fetch('x', nil)
      json_hash.fetch('h', {}).fetch('a', {}).fetch('b', {}).fetch('c', {}).fetch('d', {}).fetch('e', {}).fetch('f', {}).fetch('g', {})
      json_hash.fetch('i', []).fetch(0, []).fetch(0, []).fetch(0, []).fetch(0, []).fetch(0, []).fetch(0, []).fetch(0, nil)
    end
    # version that raises if the path is incorrect
#    perf.add('Ruby', 'fetch') { $fetch.times { json_hash['d'][1][3][1] } }
    perf.run($iter)
  end
end

if $write
  puts '-' * 80
  puts "JSON write to file Performance"
  Oj::Doc.open($json) do |doc|
    perf = Perf.new()
    perf.add('Oj::Doc', 'dump') { doc.dump(nil, 'oj.json') }
#    perf.add('Yajl', 'encode') { File.open('yajl.json', 'w') { |f| Yajl::Encoder.encode($obj, f) } }
    perf.add('JSON::Ext', 'fast_generate') { File.open('json_ext.json', 'w') { |f| f.write(JSON.fast_generate($obj)) } }
    perf.before('JSON::Ext') { JSON.generator = JSON::Ext::Generator }
    perf.run($iter)
  end
end

if $read
  puts '-' * 80
  puts "JSON read from file Performance"
  Oj::Doc.open($json) { |doc| doc.dump(nil, 'oj.json') }
#  File.open('yajl.json', 'w') { |f| Yajl::Encoder.encode($obj, f) }
  JSON.generator = JSON::Ext::Generator
  File.open('json_ext.json', 'w') { |f| f.write(JSON.fast_generate($obj)) }
  Oj::Doc.open($json) do |doc|
    perf = Perf.new()
    perf.add('Oj::Doc', 'open_file') { ::Oj::Doc.open_file('oj.json') }
#    perf.add('Yajl', 'decode') { Yajl::decoder.decode(File.read('yajl.json')) }
    perf.add('JSON::Ext', '') { JSON.parse(File.read('json_ext.json')) }
    perf.before('JSON::Ext') { JSON.parser = JSON::Ext::Parser }
    perf.run($iter)
  end
end

unless $failed.empty?
  puts "The following packages were not included for the reason listed"
  $failed.each { |tag,msg| puts "***** #{tag}: #{msg}" }
end
