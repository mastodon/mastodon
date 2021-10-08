# frozen_string_literal: true

class VideoMetadataExtractor
  attr_reader :duration, :bitrate, :video_codec, :audio_codec,
              :colorspace, :width, :height, :frame_rate

  def initialize(path)
    @path     = path
    @metadata = Oj.load(ffmpeg_command_output, mode: :strict, symbol_keys: true)

    parse_metadata
  rescue Terrapin::ExitStatusError, Oj::ParseError
    @invalid = true
  rescue Terrapin::CommandNotFoundError
    raise Paperclip::Errors::CommandNotFoundError, 'Could not run the `ffprobe` command. Please install ffmpeg.'
  end

  def valid?
    !@invalid
  end

  private

  def ffmpeg_command_output
    command = Terrapin::CommandLine.new('ffprobe', '-i :path -print_format :format -show_format -show_streams -show_error -loglevel :loglevel')
    command.run(path: @path, format: 'json', loglevel: 'fatal')
  end

  def parse_metadata
    if @metadata.key?(:format)
      @duration = @metadata[:format][:duration].to_f
      @bitrate  = @metadata[:format][:bit_rate].to_i
    end

    if @metadata.key?(:streams)
      video_streams = @metadata[:streams].select { |stream| stream[:codec_type] == 'video' }
      audio_streams = @metadata[:streams].select { |stream| stream[:codec_type] == 'audio' }

      if (video_stream = video_streams.first)
        @video_codec = video_stream[:codec_name]
        @colorspace  = video_stream[:pix_fmt]
        @width       = video_stream[:width]
        @height      = video_stream[:height]
        @frame_rate  = video_stream[:avg_frame_rate] == '0/0' ? nil : Rational(video_stream[:avg_frame_rate])
      end

      if (audio_stream = audio_streams.first)
        @audio_codec = audio_stream[:codec_name]
      end
    end

    @invalid = true if @metadata.key?(:error)
  end
end
