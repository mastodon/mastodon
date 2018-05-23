require 'rubygems'
require 'bundler/setup'

require 'benchmark'
require 'chunky_png'

files = ['pixelstream_reference.png', 'operations.png', 'clock.png']

def encode_png(image, constraints = {})
  filesize = nil
  time = Benchmark.realtime { filesize = image.to_blob(constraints).bytesize }
  [filesize, time]
end

files.each do |file|
  filename = File.join(File.dirname(__FILE__), '..', 'spec', 'resources', file)
  image = ChunkyPNG::Canvas.from_file(filename)

  puts "#{file}: #{image.width}x#{image.height} - #{image.palette.size} colors"
  puts "------------------------------------------------"
  puts "<default>         : %8d bytes in %0.4fs" % encode_png(image)
  puts ":no_compression   : %8d bytes in %0.4fs" % encode_png(image, :no_compression)
  puts ":fast_rgba        : %8d bytes in %0.4fs" % encode_png(image, :fast_rgba)
  puts ":fast_rgb         : %8d bytes in %0.4fs" % encode_png(image, :fast_rgb)
  puts ":good_compression : %8d bytes in %0.4fs" % encode_png(image, :good_compression)
  puts ":best_compression : %8d bytes in %0.4fs" % encode_png(image, :best_compression)
  puts
end
