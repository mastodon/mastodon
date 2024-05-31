# frozen_string_literal: true

module Paperclip
  class BlurhashTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :small || options[:blurhash]

      attachment.instance.blurhash = Blurhash.encode(*blurhash_params, **(options[:blurhash] || {}))

      @file
    end

    private

    def blurhash_params
      if ENV['MASTODON_USE_LIBVIPS'] == 'true'
        image = Vips::Image.thumbnail(@file.path, 100)
        [image.width, image.height, image.extract_band(0, n: 3).to_a.flatten]
      else
        pixels   = convert(':source -depth 8 RGB:-', source: File.expand_path(@file.path)).unpack('C*')
        geometry = options.fetch(:file_geometry_parser).from_file(@file)
        [geometry.width, geometry.height, pixels]
      end
    end
  end
end
