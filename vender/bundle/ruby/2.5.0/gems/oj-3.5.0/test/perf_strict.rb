#!/usr/bin/env ruby
# encoding: UTF-8

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'optparse'
require 'perf'
require 'oj'

$verbose = false
$indent = 0
$iter = 20000
$with_bignum = false
$with_nums = true
$size = 0

opts = OptionParser.new
opts.on("-v", "verbose")                                    { $verbose = true }
opts.on("-c", "--count [Int]", Integer, "iterations")       { |i| $iter = i }
opts.on("-i", "--indent [Int]", Integer, "indentation")     { |i| $indent = i }
opts.on("-s", "--size [Int]", Integer, "size (~Kbytes)")    { |i| $size = i }
opts.on("-b", "with bignum")                                { $with_bignum = true }
opts.on("-n", "without numbers")                            { $with_nums = false }
opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

if $with_nums
  $obj = {
    'a' => 'Alpha', # string
    'b' => true,    # boolean
    'c' => 12345,   # number
    'd' => [ true, [false, [-123456789, nil], 3.9676, ['Something else.', false], nil]], # mix it up array
    'e' => { 'zero' => nil, 'one' => 1, 'two' => 2, 'three' => [3], 'four' => [0, 1, 2, 3, 4] }, # hash
    'f' => nil,     # nil
    'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
    'i' => [[[[[[[nil]]]]]]]  # deep array, again, not that deep
  }
  $obj['g'] = 12345678901234567890123456789 if $with_bignum
else
  $obj = {
    'a' => 'Alpha',
    'b' => true,
    'c' => '12345',
    'd' => [ true, [false, ['12345', nil], '3.967', ['something', false], nil]],
    'e' => { 'zero' => '0', 'one' => '1', 'two' => '2' },
    'f' => nil,
    'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
    'i' => [[[[[[[nil]]]]]]]  # deep array, again, not that deep
  }
end

Oj.default_options = { :indent => $indent, :mode => :strict }

if 0 < $size
  o = $obj
  $obj = []
  (4 * $size).times do
    $obj << o
  end
end

$json = Oj.dump($obj)
$obj_json = Oj.dump($obj, :mode => :object)
#puts "*** size: #{$obj_json.size}"
#puts "*** #{$obj_json}"
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
capture_error('Oj:strict', $obj, 'load', 'dump') { |o| Oj.strict_load(Oj.dump(o, :mode => :strict)) }
capture_error('Yajl', $obj, 'encode', 'parse') { |o| require 'yajl'; Yajl::Parser.parse(Yajl::Encoder.encode(o)) }
capture_error('JSON::Ext', $obj, 'generate', 'parse') { |o|
  require 'json'
  require 'json/ext'
  JSON.generator = JSON::Ext::Generator
  JSON.parser = JSON::Ext::Parser
  JSON.parse(JSON.generate(o))
}
capture_error('JSON::Pure', $obj, 'generate', 'parse') { |o|
  require 'json/pure'
  JSON.generator = JSON::Pure::Generator
  JSON.parser = JSON::Pure::Parser
  JSON.parse(JSON.generate(o))
}

if $verbose
  puts "json:\n#{$json}\n"
  puts "object json:\n#{$obj_json}\n"
  puts "Oj loaded object:\n#{Oj.strict_load($json)}\n"
  puts "Yajl loaded object:\n#{Yajl::Parser.parse($json)}\n"
  puts "JSON loaded object:\n#{JSON::Ext::Parser.new($json).parse}\n"
end

puts '-' * 80
puts "Strict Parse Performance"
perf = Perf.new()
unless $failed.has_key?('JSON::Ext')
  perf.add('JSON::Ext', 'parse') { JSON.parse($json) }
  perf.before('JSON::Ext') { JSON.parser = JSON::Ext::Parser }
end
unless $failed.has_key?('JSON::Pure')
  perf.add('JSON::Pure', 'parse') { JSON.parse($json) }
  perf.before('JSON::Pure') { JSON.parser = JSON::Pure::Parser }
end
unless $failed.has_key?('Oj:strict')
  perf.add('Oj:strict', 'strict_load') { Oj.strict_load($json) }
end
perf.add('Yajl', 'parse') { Yajl::Parser.parse($json) } unless $failed.has_key?('Yajl')
perf.run($iter)

puts '-' * 80
puts "Strict Dump Performance"
perf = Perf.new()
unless $failed.has_key?('JSON::Ext')
  perf.add('JSON::Ext', 'dump') { JSON.generate($obj) }
  perf.before('JSON::Ext') { JSON.generator = JSON::Ext::Generator }
end
unless $failed.has_key?('JSON::Pure')
  perf.add('JSON::Pure', 'generate') { JSON.generate($obj) }
  perf.before('JSON::Pure') { JSON.generator = JSON::Pure::Generator }
end
unless $failed.has_key?('Oj:strict')
  perf.add('Oj:strict', 'dump') { Oj.dump($obj, :mode => :strict) }
end
perf.add('Yajl', 'encode') { Yajl::Encoder.encode($obj) } unless $failed.has_key?('Yajl')
perf.run($iter)

puts
puts '-' * 80
puts

unless $failed.empty?
  puts "The following packages were not included for the reason listed"
  $failed.each { |tag,msg| puts "***** #{tag}: #{msg}" }
end
