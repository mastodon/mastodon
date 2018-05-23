require 'rubygems'
require 'bundler/setup'
require 'chunky_png'

module PNGSuite

  def png_suite_file(kind, file)
    File.join(png_suite_dir(kind), file)
  end

  def png_suite_dir(kind)
    File.expand_path("./png_suite/#{kind}", File.dirname(__FILE__))
  end

  def png_suite_files(kind, pattern = '*.png')
    Dir[File.join(png_suite_dir(kind), pattern)]
  end
end


module ResourceFileHelper

  def resource_file(name)
    File.expand_path("./resources/#{name}", File.dirname(__FILE__))
  end

  def resource_data(name)
    data = nil
    File.open(resource_file(name), 'rb') { |f| data = f.read }
    data
  end

  def reference_canvas(name)
    ChunkyPNG::Canvas.from_file(resource_file("#{name}.png"))
  end

  def reference_image(name)
    ChunkyPNG::Image.from_file(resource_file("#{name}.png"))
  end

  def display(png)
    filename = resource_file('_tmp.png')
    png.save(filename)
    `open #{filename}`
  end
end

module ChunkOperationsHelper

  def serialized_chunk(chunk)
    chunk.write(stream = StringIO.new)
    stream.rewind
    ChunkyPNG::Chunk.read(stream)
  end
end

RSpec.configure do |config|
  config.extend PNGSuite
  config.include PNGSuite
  config.include ResourceFileHelper
  config.include ChunkOperationsHelper

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
