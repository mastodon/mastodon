# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated GIFs and PNGs to videos

  class GifvTranscoder < Paperclip::Processor
    def make
      final_file = Paperclip::Transcoder.make(file, options, attachment)

      if options[:style] == :original
        attachment.instance.file_file_name    = "#{File.basename(attachment.instance.file_file_name, '.*')}.mp4"
        attachment.instance.file_content_type = 'video/mp4'
        attachment.instance.type              = MediaAttachment.types[:gifv]
      end

      final_file
    end
  end
end
