# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated gifs to webm
  class GifTranscoder < Paperclip::Processor
    def make
      num_frames = identify('-format %n :file', file: file.path).to_i

      return file unless options[:style] == :original && num_frames > 1

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      attachment.instance.file_file_name    = 'media.webm'
      attachment.instance.file_content_type = 'video/webm'
      attachment.instance.type              = MediaAttachment.types[:gifv]

      final_file
    end
  end
end
