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
$size = 0

opts = OptionParser.new
opts.on("-v", "verbose")                                    { $verbose = true }
opts.on("-c", "--count [Int]", Integer, "iterations")       { |i| $iter = i }
opts.on("-i", "--indent [Int]", Integer, "indentation")     { |i| $indent = i }
opts.on("-s", "--size [Int]", Integer, "size (~Kbytes)")    { |i| $size = i }
opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

def capture_error(tag, orig, load_key, dump_key, &blk)
  begin
    obj = blk.call(orig)
    puts obj unless orig == obj
    raise "#{tag} #{dump_key} and #{load_key} did not return the same object as the original." unless orig == obj
  rescue Exception => e
    $failed[tag] = "#{e.class}: #{e.message}"
  end
end

# Verify that all packages dump and load correctly and return the same Object as the original.
capture_error('Oj:compat', $obj, 'load', 'dump') { |o| Oj.compat_load(Oj.dump(o, :mode => :compat)) }
capture_error('JSON::Ext', $obj, 'generate', 'parse') { |o|
  require 'json'
  require 'json/ext'
  JSON.generator = JSON::Ext::Generator
  JSON.parser = JSON::Ext::Parser
  JSON.load(JSON.generate(o))
}

module One
  module Two
    module Three
      class Empty

        def initialize()
          @a = 1
          @b = 2
          @c = 3
        end

        def eql?(o)
          self.class == o.class && @a == o.a && @b = o.b && @c = o.c
        end
        alias == eql?

        def as_json(*a)
          {JSON.create_id => self.class.name, 'a' => @a, 'b' => @b, 'c' => @c }
        end
        
        def to_json(*a)
          JSON.generate(as_json())
        end

        def self.json_create(h)
          self.new()
        end
      end # Empty
    end # Three
  end # Two
end # One

$obj = {
  'a' => 'Alpha', # string
  'b' => true,    # boolean
  'c' => 12345,   # number
  'd' => [ true, [false, [-123456789, nil], 3.9676, ['Something else.', false], nil]], # mix it up array
  'e' => { 'zero' => nil, 'one' => 1, 'two' => 2, 'three' => [3], 'four' => [0, 1, 2, 3, 4] }, # hash
  'f' => nil,     # nil
  'g' => One::Two::Three::Empty.new(),
  'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
  'i' => [[[[[[[nil]]]]]]]  # deep array, again, not that deep
}

Oj.default_options = { :indent => $indent, :mode => :compat, :use_to_json => true, :create_additions => true, :create_id => '^o' }

if 0 < $size
  s = Oj.dump($obj).size + 1
  cnt = $size * 1024 / s
  o = $obj
  $obj = []
  cnt.times do
    $obj << o
  end
end

$json = Oj.dump($obj)
$failed = {} # key is same as String used in tests later

if $verbose
  puts "size: #{$json.size}"
  puts "json:\n#{$json}\n"
  puts "Oj:compat loaded object:\n#{Oj.compat_load($json)}\n"
  puts "JSON loaded object:\n#{JSON::Ext::Parser.new($json).parse}\n"
end

puts '-' * 80
puts "Compat Parse Performance"
perf = Perf.new()
unless $failed.has_key?('JSON::Ext')
  perf.add('JSON::Ext', 'parse') { JSON.load($json) }
  perf.before('JSON::Ext') { JSON.parser = JSON::Ext::Parser }
end
unless $failed.has_key?('Oj:compat')
  perf.add('Oj:compat', 'compat_load') { Oj.compat_load($json) }
end
perf.run($iter)

puts
puts '-' * 80
puts

unless $failed.empty?
  puts "The following packages were not included for the reason listed"
  $failed.each { |tag,msg| puts "***** #{tag}: #{msg}" }
end
