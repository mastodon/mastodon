#!/usr/bin/env ruby -wW2

if $0 == __FILE__
  $: << '.'
  $: << '..'
  $: << '../lib'
  $: << '../ext'
end

require 'pp'
require 'sample/doc'

def sample_doc(size=3)
  colors = [ :black, :gray, :white, :red, :blue, :yellow, :green, :purple, :orange ]

  d = ::Sample::Doc.new('Sample')

  # add some history
  (0..size * 10).each do |i|
    d.add_change("Changed at t+#{i}.")
  end

  # add some layers
  (1..size).each do |i|
    layer = ::Sample::Layer.new("Layer-#{i}")
    (1..size).each do |j|
      g = ::Sample::Group.new
      (1..size).each do |k|
        g2 = ::Sample::Group.new
        r = ::Sample::Rect.new(j * 40 + 10.0, i * 10.0,
                               10.123456 / k, 10.0 / k, colors[(i + j + k) % colors.size])
        r.add_prop(:part_of, layer.name)
        g2 << r
        g2 << ::Sample::Text.new("#{k} in #{j}", r.left, r.top, r.width, r.height)
        g << g2
      end
      g2 = ::Sample::Group.new
      (1..size).each do |k|
        o = ::Sample::Oval.new(j * 40 + 12.0, i * 10.0 + 2.0,
                               6.0 / k, 6.0 / k, colors[(i + j + k) % colors.size])
        o.add_prop(:inside, true)
        g << o
      end
      g << g2
      layer << g
    end
    d.layers[layer.name] = layer
  end

  # some properties
  d.add_prop(:purpose, 'an example')

  d
end
