# frozen_string_literal: true

module Paperclip
  class BlurhashTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :small || options[:blurhash]

      image = Vips::Image.thumbnail(@file.path, 100)

      attachment.instance.blurhash = Blurhash.encode(image.width, image.height, image.to_a.flatten, **(options[:blurhash] || {}))

      @file
    end
  end
end
