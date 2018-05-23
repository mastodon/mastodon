#!/usr/bin/env ruby -wW2

if $0 == __FILE__
  $: << '.'
  $: << '..'
  $: << '../lib'
  $: << '../ext'
end

require 'pp'
require 'oj'

def sample_json(size=3)
  colors = [ :black, :gray, :white, :red, :blue, :yellow, :green, :purple, :orange ]
  container = []
  size.times do |i|
    box = {
      'color' => colors[i % colors.size],
      'fragile' => (0 == (i % 2)),
      'width' => i,
      'height' => i,
      'depth' => i,
      'weight' => i * 1.3,
      'address' => {
        'street' => "#{i} Main Street",
        'city' => 'Sity',
        'state' => nil
      }
    }
    container << box
  end
  container
end

if $0 == __FILE__
  File.open('sample.json', "w") { |f| f.write(Oj.dump(sample_json(3), :indent => 2)) }
end
