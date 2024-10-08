# frozen_string_literal: true

module Paperclip
  class BlurhashTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :small || options[:blurhash]

      width, height, data = blurhash_params
      # Guard against segfaults if data has unexpected size
      raise RangeError, "Invalid image data size (expected #{width * height * 3}, got #{data.size})" if data.size != width * height * 3 # TODO: should probably be another exception type

      attachment.instance.blurhash = Blurhash.encode(width, height, data, **(options[:blurhash] || {}))

      @file
    rescue Vips::Error => e
      raise Paperclip::Error, "Error while generating blurhash for #{@basename}: #{e}"
    end

    private

    def blurhash_params
      image = Vips::Image.thumbnail(@file.path, 100)
      [image.width, image.height, image.colourspace(:srgb).extract_band(0, n: 3).to_a.flatten]
    end
  end
end
