# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated gifs to webm
  class GifTranscoder < Paperclip::Processor
    def make
      num_frames = identify('-format %n :file', file: file.path).to_i

      unless options[:style] == :original && num_frames > 1
        tmp_file = Paperclip::TempfileFactory.new.generate(attachment.instance.file_file_name)
        tmp_file << file.read
        return tmp_file
      end

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      attachment.instance.file_file_name    = 'media.mp4'
      attachment.instance.file_content_type = 'video/mp4'
      attachment.instance.type              = MediaAttachment.types[:gifv]

      final_file
    end
  end
end
