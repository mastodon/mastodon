# frozen_string_literal: true

module Paperclip
  class BlurhashTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :small || options[:blurhash]

      pixels   = convert(':source -depth 8 RGB:-', source: File.expand_path(@file.path)).unpack('C*')
      geometry = options.fetch(:file_geometry_parser).from_file(@file)

      attachment.instance.blurhash = Blurhash.encode(geometry.width, geometry.height, pixels, **(options[:blurhash] || {}))

      @file
    end
  end
end
