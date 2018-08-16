# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated gifs to webm
  class GifTranscoder < Paperclip::Processor
    def make
      return File.open(@file.path) unless needs_convert?

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      attachment.instance.file_file_name    = File.basename(attachment.instance.file_file_name, '.*') + '.mp4'
      attachment.instance.file_content_type = 'video/mp4'
      attachment.instance.type              = MediaAttachment.types[:gifv]

      final_file
    end

    private

    def needs_convert?
      num_frames = identify('-format %n :file', file: file.path).to_i
      options[:style] == :original && num_frames > 1
    end
  end
end
