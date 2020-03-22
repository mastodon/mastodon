# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to check when uploaded videos are actually gifv's
  class VideoTranscoder < Paperclip::Processor
    def make
      movie = FFMPEG::Movie.new(@file.path)

      attachment.instance.type = MediaAttachment.types[:gifv] unless movie.audio_codec

      Paperclip::Transcoder.make(file, actual_options(movie), attachment)
    end

    private

    def actual_options(movie)
      opts = options[:passthrough_options]
      if opts && opts[:video_codecs].include?(movie.video_codec) && opts[:audio_codecs].include?(movie.audio_codec) && opts[:colorspaces].include?(movie.colorspace)
        opts[:options]
      else
        options
      end
    end
  end
end
