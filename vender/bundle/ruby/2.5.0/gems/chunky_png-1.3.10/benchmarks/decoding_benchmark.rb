require 'rubygems'
require 'bundler/setup'

require 'benchmark'
require 'chunky_png'

def image_file(name)
  File.join(File.dirname(__FILE__), '..', 'spec', 'resources', name)
end

def image_data(name)
  data = nil
  File.open(image_file(name), 'rb') { |f| data = f.read }
  data
end

no_filtering_stream    = image_data('pixelstream_fast_rgba.png')
up_filtering_stream    = image_data('pixelstream_reference.png')
paeth_filtering_stream = image_data('pixelstream_best_compression.png')
rgba_pixelstream       = image_data('pixelstream.rgba')
rgb_pixelstream        = image_data('pixelstream.rgb')

n = (ENV['N'] || '5').to_i

puts "---------------------------------------------"
puts "ChunkyPNG (#{ChunkyPNG::VERSION}) decoding benchmark (n=#{n})"
puts "---------------------------------------------"
puts

Benchmark.bmbm do |x|
  x.report('PNG - no filtering')    { n.times { ChunkyPNG::Image.from_blob(no_filtering_stream) } }
  x.report('PNG - UP filtering')    { n.times { ChunkyPNG::Image.from_blob(up_filtering_stream) } }
  x.report('PNG - PAETH filtering') { n.times { ChunkyPNG::Image.from_blob(paeth_filtering_stream) } }
  x.report('From RGBA pixelstream') { n.times { ChunkyPNG::Image.from_rgba_stream(240, 180, rgba_pixelstream) } }
  x.report('From RGB pixelstream')  { n.times { ChunkyPNG::Image.from_rgb_stream(240, 180, rgb_pixelstream) } }
end
