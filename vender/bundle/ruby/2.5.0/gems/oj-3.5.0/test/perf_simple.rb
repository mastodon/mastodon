#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'optparse'
require 'yajl'
require 'json'
require 'json/pure'
require 'json/ext'
require 'msgpack'
require 'oj'
require 'ox'

class Jazz
  def initialize()
    @boolean = true
    @number = 58
    @string = "A string"
    @array = [true, false, nil]
    @hash = { 'one' => 1, 'two' => 2 }
  end
  def to_json()
    %{
    { "boolean":#{@boolean},
      "number":#{@number},
      "string":#{@string},
      "array":#{@array},
      "hash":#{@hash},
    }
}
  end
  def to_hash()
    { 'boolean' => @boolean,
      'number' => @number,
      'string' => @string,
      'array' => @array,
      'hash' => @hash,
    }
  end
  def to_msgpack(out='')
    to_hash().to_msgpack(out)
  end
end

$indent = 2
$iter = 10000
$with_object = true
$with_bignum = true
$with_nums = true

opts = OptionParser.new
opts.on("-c", "--count [Int]", Integer, "iterations")       { |i| $iter = i }
opts.on("-i", "--indent [Int]", Integer, "indentation")     { |i| $indent = i }
opts.on("-o", "without objects")                            { $with_object = false }
opts.on("-b", "without bignum")                             { $with_bignum = false }
opts.on("-n", "without numbers")                            { $with_nums = false }
opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

if $with_nums
  obj = {
    'a' => 'Alpha',
    'b' => true,
    'c' => 12345,
    'd' => [ true, [false, [12345, nil], 3.967, ['something', false], nil]],
    'e' => { 'one' => 1, 'two' => 2 },
    'f' => nil,
  }
  obj['g'] = Jazz.new() if $with_object
  obj['h'] = 12345678901234567890123456789 if $with_bignum
else
  obj = {
    'a' => 'Alpha',
    'b' => true,
    'c' => '12345',
    'd' => [ true, [false, ['12345', nil], '3.967', ['something', false], nil]],
    'e' => { 'one' => '1', 'two' => '2' },
    'f' => nil,
  }
end

Oj.default_options = { :indent => $indent, :mode => :object }

s = Oj.dump(obj)

xml = Ox.dump(obj, :indent => $indent)

puts

# Put Oj in strict mode so it only create JSON native types instead of the
# original Ruby Objects. None of the other packages other than Ox support
# Object recreation so no need for Oj to do it in the performance tests.
Oj.default_options = { :mode => :strict }
parse_results = { :oj => 0.0, :yajl => 0.0, :msgpack => 0.0, :pure => 0.0, :ext => 0.0, :ox => 0.0 }

start = Time.now
$iter.times do
  Oj.load(s)
end
dt = Time.now - start
base_dt = dt
parse_results[:oj] = dt
puts "%d Oj.load()s in %0.3f seconds or %0.1f loads/msec" % [$iter, dt, $iter/dt/1000.0]

start = Time.now
$iter.times do
  Yajl::Parser.parse(s)
end
dt = Time.now - start
if base_dt < dt
  base_dt = dt
  base_name = 'Yajl'
end
parse_results[:yajl] = dt
puts "%d Yajl::Parser.parse()s in %0.3f seconds or %0.1f parses/msec" % [$iter, dt, $iter/dt/1000.0]

begin
  JSON.parser = JSON::Ext::Parser
  start = Time.now
  $iter.times do
    JSON.parse(s)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'JSON::Ext'
  end
  parse_results[:ext] = dt
  puts "%d JSON::Ext::Parser parse()s in %0.3f seconds or %0.1f parses/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  puts "JSON::Ext failed: #{e.class}: #{e.message}"
end

begin
  JSON.parser = JSON::Pure::Parser
  start = Time.now
  $iter.times do
    JSON.parse(s)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'JSON::Pure'
  end
  parse_results[:pure] = dt
  puts "%d JSON::Pure::Parser parse()s in %0.3f seconds or %0.1f parses/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  puts "JSON::Pure failed: #{e.class}: #{e.message}"
end

begin
  mp = MessagePack.pack(obj)
  start = Time.now
  $iter.times do
    MessagePack.unpack(mp)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'MessagePack'
  end
  parse_results[:msgpack] = dt
  puts "%d MessagePack.unpack()s in %0.3f seconds or %0.1f packs/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  puts "MessagePack failed: #{e.class}: #{e.message}"
end

start = Time.now
$iter.times do
  Ox.load(xml)
end
dt = Time.now - start
parse_results[:ox] = dt
puts "%d Ox.load()s in %0.3f seconds or %0.1f loads/msec" % [$iter, dt, $iter/dt/1000.0]

puts "Parser results:"
puts "gem       seconds  parses/msec  X faster than #{base_name} (higher is better)"
parse_results.each do |name,dt|
  if 0.0 == dt
    puts "#{name} failed to generate JSON"
    next
  end
  puts "%-7s  %6.3f    %5.1f        %4.1f" % [name, dt, $iter/dt/1000.0, base_dt/dt]
end

puts

# Back to object mode for best performance when dumping.
Oj.default_options = { :indent => $indent, :mode => :object }
dump_results = { :oj => 0.0, :yajl => 0.0, :msgpack => 0.0, :pure => 0.0, :ext => 0.0, :ox => 0.0 }

start = Time.now
$iter.times do
  Oj.dump(obj)
end
dt = Time.now - start
base_dt = dt
base_name = 'Oj'
parse_results[:oj] = dt
puts "%d Oj.dump()s in %0.3f seconds or %0.1f dumps/msec" % [$iter, dt, $iter/dt/1000.0]

start = Time.now
$iter.times do
  Yajl::Encoder.encode(obj)
end
dt = Time.now - start
if base_dt < dt
  base_dt = dt
  base_name = 'Yajl'
end
parse_results[:yajl] = dt
puts "%d Yajl::Encoder.encode()s in %0.3f seconds or %0.1f encodes/msec" % [$iter, dt, $iter/dt/1000.0]

begin
  JSON.parser = JSON::Ext::Parser
  start = Time.now
  $iter.times do
    JSON.generate(obj)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'JSON::Ext'
  end
  parse_results[:pure] = dt
  puts "%d JSON::Ext generate()s in %0.3f seconds or %0.1f generates/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  parse_results[:ext] = 0.0
  puts "JSON::Ext failed: #{e.class}: #{e.message}"
end

begin
  JSON.parser = JSON::Pure::Parser
  start = Time.now
  $iter.times do
    JSON.generate(obj)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'JSON::Pure'
  end
  parse_results[:pure] = dt
  puts "%d JSON::Pure generate()s in %0.3f seconds or %0.1f generates/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  parse_results[:pure] = 0.0
  puts "JSON::Pure failed: #{e.class}: #{e.message}"
end

begin
  start = Time.now
  $iter.times do
    MessagePack.pack(obj)
  end
  dt = Time.now - start
  if base_dt < dt
    base_dt = dt
    base_name = 'MessagePack'
  end
  parse_results[:msgpack] = dt
  puts "%d Msgpack()s in %0.3f seconds or %0.1f unpacks/msec" % [$iter, dt, $iter/dt/1000.0]
rescue Exception => e
  parse_results[:msgpack] = 0.0
  puts "MessagePack failed: #{e.class}: #{e.message}"
end

start = Time.now
$iter.times do
  Ox.dump(obj)
end
dt = Time.now - start
parse_results[:ox] = dt
puts "%d Ox.dump()s in %0.3f seconds or %0.1f dumps/msec" % [$iter, dt, $iter/dt/1000.0]

puts "Parser results:"
puts "gem       seconds  dumps/msec  X faster than #{base_name} (higher is better)"
parse_results.each do |name,dt|
  if 0.0 == dt
    puts "#{name} failed to generate JSON"
    next
  end
  puts "%-7s  %6.3f    %5.1f       %4.1f" % [name, dt, $iter/dt/1000.0, base_dt/dt]
end

puts
