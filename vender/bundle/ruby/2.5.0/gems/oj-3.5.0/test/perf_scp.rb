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
$iter = 50000
$with_bignum = false
$size = 0

opts = OptionParser.new
opts.on("-v", "verbose")                                  { $verbose = true }
opts.on("-c", "--count [Int]", Integer, "iterations")     { |i| $iter = i }
opts.on("-i", "--indent [Int]", Integer, "indentation")   { |i| $indent = i }
opts.on("-s", "--size [Int]", Integer, "size (~Kbytes)")    { |i| $size = i }
opts.on("-b", "with bignum")                                { $with_bignum = true }
opts.on("-h", "--help", "Show this display")              { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

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

if 0 < $size
  o = $obj
  $obj = []
  (4 * $size).times do
    $obj << o
  end
end

Oj.default_options = { :indent => $indent, :mode => :compat }

$json = Oj.dump($obj)
$failed = {} # key is same as String used in tests later

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

class NoHandler < Oj::ScHandler
  def initialize()
  end
end # NoHandler

class AllHandler < Oj::ScHandler
  def initialize()
  end

  def hash_start()
    return nil
  end

  def hash_end()
  end

  def array_start()
    return nil
  end

  def array_end()
  end

  def add_value(value)
  end

  def hash_set(h, key, value)
  end
  
  def array_append(a, value)
  end

end # AllHandler

saj_handler = AllSaj.new()
no_saj = NoSaj.new()

sc_handler = AllHandler.new()
no_handler = NoHandler.new()

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
perf.add('Oj::Scp', 'all') { Oj.sc_parse(sc_handler, $json) }
perf.add('Oj::Scp', 'none') { Oj.sc_parse(no_handler, $json) }
perf.add('Yajl', 'parse') { Yajl::Parser.parse($json) } unless $failed.has_key?('Yajl')
perf.add('JSON::Ext', 'parse') { JSON::Ext::Parser.new($json).parse } unless $failed.has_key?('JSON::Ext')
perf.run($iter)

unless $failed.empty?
  puts "The following packages were not included for the reason listed"
  $failed.each { |tag,msg| puts "***** #{tag}: #{msg}" }
end
