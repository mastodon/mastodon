# frozen_string_literal: true

require 'mime/types/columnar'

module Paperclip
  class ImageExtractor < Paperclip::Processor
    IMAGE_EXTRACTION_OPTIONS = {
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          vf: 'scale=\'min(400\, iw):min(400\, ih)\':force_original_aspect_ratio=decrease',
        }.freeze,
      }.freeze,
      format: 'png',
      time: -1,
      file_geometry_parser: FastGeometryParser,
    }.freeze

    def make
      return @file unless options[:style] == :original

      image = begin
        begin
          Paperclip::Transcoder.make(file, IMAGE_EXTRACTION_OPTIONS.dup, attachment)
        rescue Paperclip::Error, ::Av::CommandError
          nil
        end
      end

      unless image.nil?
        begin
          attachment.instance.thumbnail = image if image.size.positive?
        ensure
          # Paperclip does not automatically delete the source file of
          # a new attachment while working on copies of it, so we need
          # to make sure it's cleaned up

          begin
            FileUtils.rm(image)
          rescue Errno::ENOENT
            nil
          end
        end
      end

      @file
    end
  end
end
