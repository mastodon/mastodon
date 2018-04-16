#!/usr/bin/env ruby

$: << '.'
$: << '../lib'
$: << '../ext'

if __FILE__ == $0
  if (i = ARGV.index('-I'))
    x,path = ARGV.slice!(i, 2)
    $: << path
  end
end

require 'optparse'
require 'ox'
require 'oj'
require 'perf'
require 'sample'
require 'files'

$circular = false
$indent = 0
$allow_gc = true

do_sample = false
do_files = false

do_load = false
do_dump = false
do_read = false
do_write = false
$iter = 1000
$mult = 1

opts = OptionParser.new
opts.on("-c", "circular options")                           { $circular = true }

opts.on("-x", "use sample instead of files")                { do_sample = true }
opts.on("-g", "no GC during parsing")                       { $allow_gc = false }

opts.on("-s", "load and dump as sample Ruby object")        { do_sample = true }
opts.on("-f", "load and dump as files Ruby object")         { do_files = true }

opts.on("-l", "load")                                       { do_load = true }
opts.on("-d", "dump")                                       { do_dump = true }
opts.on("-r", "read")                                       { do_read = true }
opts.on("-w", "write")                                      { do_write = true }
opts.on("-a", "load, dump, read and write")                 { do_load = true; do_dump = true; do_read = true; do_write = true }

opts.on("-i", "--iterations [Int]", Integer, "iterations")  { |i| $iter = i }
opts.on("-m", "--multiply [Int]", Integer, "multiplier")    { |i| $mult = i }

opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

$obj = nil
$xml = nil
$mars = nil
$json = nil

unless do_load || do_dump || do_read || do_write
  do_load = true
  do_dump = true
  do_read = true
  do_write = true
end

# prepare all the formats for input
if files.empty?
  $obj = []
  $mult.times do
    $obj << (do_sample ? sample_doc(2) : files('..'))
  end

  $mars = Marshal.dump($obj)
  $xml = Ox.dump($obj, :indent => $indent, :circular => $circular)
  $json = Oj.dump($obj, :indent => $indent, :circular => $circular, :mode => :object)
  File.open('sample.xml', 'w') { |f| f.write($xml) }
  File.open('sample.json', 'w') { |f| f.write($json) }
  File.open('sample.marshal', 'w') { |f| f.write($mars) }
else
  puts "loading and parsing #{files}\n\n"
  data = files.map do |f|
    $xml = File.read(f)
    $obj = Ox.load($xml);
    $mars = Marshal.dump($obj)
    $json = Oj.dump($obj, :indent => $indent, :circular => $circular)
  end
end

Oj.default_options = { :mode => :object, :indent => $indent, :circular => $circular, :allow_gc => $allow_gc }
#puts "json: #{$json.size}"
#puts "xml: #{$xml.size}"
#puts "marshal: #{$mars.size}"


if do_load
  puts '-' * 80
  puts "Load Performance"
  perf = Perf.new()
  perf.add('Oj.object', 'load') { Oj.object_load($json) }
  perf.add('Ox', 'load') { Ox.load($xml, :mode => :object) }
  perf.add('Marshal', 'load') { Marshal.load($mars) }
  perf.run($iter)
end

if do_dump
  puts '-' * 80
  puts "Dump Performance"
  perf = Perf.new()
  perf.add('Oj', 'dump') { Oj.dump($obj) }
  perf.add('Ox', 'dump') { Ox.dump($obj, :indent => $indent, :circular => $circular) }
  perf.add('Marshal', 'dump') { Marshal.dump($obj) }
  perf.run($iter)
end

if do_read
  puts '-' * 80
  puts "Read from file Performance"
  perf = Perf.new()
  perf.add('Oj', 'load') { Oj.load_file('sample.json') }
  #perf.add('Oj', 'load') { Oj.load(File.read('sample.json')) }
  perf.add('Ox', 'load_file') { Ox.load_file('sample.xml', :mode => :object) }
  perf.add('Marshal', 'load') { Marshal.load(File.new('sample.marshal')) }
  perf.run($iter)
end

if do_write
  puts '-' * 80
  puts "Write to file Performance"
  perf = Perf.new()
  perf.add('Oj', 'to_file') { Oj.to_file('sample.json', $obj) }
  perf.add('Ox', 'to_file') { Ox.to_file('sample.xml', $obj, :indent => $indent, :circular => $circular) }
  perf.add('Marshal', 'dump') { Marshal.dump($obj, File.new('sample.marshal', 'w')) }
  perf.run($iter)
end


