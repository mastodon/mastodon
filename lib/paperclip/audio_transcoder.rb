# frozen_string_literal: true

module Paperclip
  class AudioTranscoder < Paperclip::Processor
    def make
      final_file = Paperclip::Transcoder.make(file, options, attachment)
      
      attachment.instance.file_file_name    = 'media.mp4'
      attachment.instance.file_content_type = 'video/mp4'
      attachment.instance.type              = MediaAttachment.types[:video]

      final_file
    end
  end
end
