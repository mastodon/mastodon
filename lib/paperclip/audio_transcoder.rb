# frozen_string_literal: true

module Paperclip
  class AudioTranscoder < Paperclip::Processor
    def make
      max_aud_len = (ENV['MAX_AUDIO_LENGTH'] || 60.0).to_f

      meta = ::Av.cli.identify(@file.path)
      # {:length=>"0:00:02.14", :duration=>2.14, :audio_encode=>"mp3", :audio_bitrate=>"44100 Hz", :audio_channels=>"mono"}
      if meta[:duration] > max_aud_len
        raise Mastodon::ValidationError, "Audio uploads must be less than #{max_aud_len} seconds in length."
      end
      
      final_file = Paperclip::Transcoder.make(file, options, attachment)
      
      attachment.instance.file_file_name    = 'media.mp4'
      attachment.instance.file_content_type = 'video/mp4'
      attachment.instance.type              = MediaAttachment.types[:video]

      final_file
    end
  end
end
