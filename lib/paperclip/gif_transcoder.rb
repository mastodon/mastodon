# frozen_string_literal: true

require_relative '../../lib/gif_reader'

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated GIFs to videos

  class GifTranscoder < Paperclip::Processor
    def make
      return File.open(@file.path) unless needs_convert?

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      if options[:style] == :original
        attachment.instance.file_file_name    = "#{File.basename(attachment.instance.file_file_name, '.*')}.mp4"
        attachment.instance.file_content_type = 'video/mp4'
        attachment.instance.type              = MediaAttachment.types[:gifv]
      end

      final_file
    end

    private

    def needs_convert?
      GifReader.animated?(file.path)
    end
  end
end
