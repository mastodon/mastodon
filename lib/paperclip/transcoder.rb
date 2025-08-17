# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to check when uploaded videos are actually gifv's
  class Transcoder < Paperclip::Processor
    # This is the H.264 "High" value taken from https://www.dr-lex.be/info-stuff/videocalc.html
    BITS_PER_PIXEL = 0.11

    def initialize(file, options = {}, attachment = nil)
      super

      @current_format      = File.extname(@file.path)
      @basename            = File.basename(@file.path, @current_format)
      @format              = options[:format]
      @time                = options[:time] || 3
      @passthrough_options = options[:passthrough_options]
      @convert_options     = options[:convert_options].dup
      @vfr_threshold       = options[:vfr_frame_rate_threshold]
    end

    def make
      metadata = VideoMetadataExtractor.new(@file.path)

      raise Paperclip::Error, "Error while transcoding #{@file.path}: unsupported file" unless metadata.valid?

      update_attachment_type(metadata)
      update_options_from_metadata(metadata)

      destination = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      destination.binmode

      @output_options = @convert_options[:output]&.dup || {}
      @input_options  = @convert_options[:input]&.dup  || {}

      case @format.to_s
      when /jpg$/, /jpeg$/, /png$/, /gif$/
        @input_options['ss'] = @time

        @output_options['f']       = 'image2'
        @output_options['vframes'] = 1
      when 'mp4'
        unless eligible_to_passthrough?(metadata)
          size_limit_in_bits = MediaAttachment::VIDEO_LIMIT * 8
          desired_bitrate = (metadata.width * metadata.height * 30 * BITS_PER_PIXEL).floor
          duration = [metadata.duration, 1].max
          maximum_bitrate = (size_limit_in_bits / duration).floor - 192_000 # Leave some space for the audio stream
          bitrate = [desired_bitrate, maximum_bitrate].min

          @output_options['b:v']     = bitrate
          @output_options['maxrate'] = bitrate + 192_000
          @output_options['bufsize'] = bitrate * 5

          if high_vfr?(metadata)
            # TODO: change to `fps_mode` in the future, as `vsync` is being deprecated
            @output_options['vsync'] = 'vfr'
          end
        end
      end

      command_arguments, interpolations = prepare_command(destination)

      begin
        command = Terrapin::CommandLine.new(Rails.configuration.x.ffmpeg_binary, command_arguments.join(' '), logger: Paperclip.logger)
        command.run(interpolations)
      rescue Terrapin::ExitStatusError => e
        raise Paperclip::Error, "Error while transcoding #{@basename}: #{e}"
      rescue Terrapin::CommandNotFoundError
        raise Paperclip::Errors::CommandNotFoundError, 'Could not run the `ffmpeg` command. Please install ffmpeg.'
      end

      destination
    end

    private

    def prepare_command(destination)
      command_arguments  = ['-nostdin']
      interpolations     = {}
      interpolation_keys = 0

      @input_options.each_pair do |key, value|
        interpolation_key = interpolation_keys
        command_arguments << "-#{key} :#{interpolation_key}"
        interpolations[interpolation_key] = value
        interpolation_keys += 1
      end

      command_arguments << '-i :source'
      interpolations[:source] = @file.path

      @output_options.each_pair do |key, value|
        interpolation_key = interpolation_keys
        command_arguments << "-#{key} :#{interpolation_key}"
        interpolations[interpolation_key] = value
        interpolation_keys += 1
      end

      command_arguments << '-y :destination'
      interpolations[:destination] = destination.path

      [command_arguments, interpolations]
    end

    def update_options_from_metadata(metadata)
      return unless eligible_to_passthrough?(metadata)

      @format          = @passthrough_options[:options][:format] || @format
      @time            = @passthrough_options[:options][:time]   || @time
      @convert_options = @passthrough_options[:options][:convert_options].dup
    end

    def high_vfr?(metadata)
      @vfr_threshold && metadata.r_frame_rate && metadata.r_frame_rate > @vfr_threshold
    end

    def eligible_to_passthrough?(metadata)
      @passthrough_options && @passthrough_options[:video_codecs].include?(metadata.video_codec) && @passthrough_options[:audio_codecs].include?(metadata.audio_codec) && @passthrough_options[:colorspaces].include?(metadata.colorspace)
    end

    def update_attachment_type(metadata)
      @attachment.instance.type = MediaAttachment.types[:gifv] unless metadata.audio_codec
    end
  end
end
