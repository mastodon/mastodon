require 'tmpdir'

module Av
  module Commands
    # Common features across commands
    class Base
      attr_accessor :options
      attr_accessor :command_name
      attr_accessor :input_params
      attr_accessor :output_params
      attr_accessor :output_format
      attr_accessor :audio_filters
      attr_accessor :video_filters
      attr_accessor :default_params

      attr_accessor :source
      attr_accessor :destination

      def initialize(options = {})
        reset_input_filters
        reset_output_filters
        reset_default_filters
        @options = options
      end

      def add_source src
        @source = src
      end

      def add_destination dest
        # infer format from extension unless format has already been set
        if @output_format.nil?
          output_format File.extname(dest)
        end
        @destination = dest
      end

      def reset_input_filters
        @input_params = ParamHash.new
        @audio_filters = ParamHash.new
        @video_filters = ParamHash.new
      end

      def reset_output_filters
        @output_params = ParamHash.new
      end

      def reset_default_filters
        @default_params = ParamHash.new
      end

      def add_input_param *param
        p = parse_param(param)
        ::Av.log "Adding input parameter #{p}"
        @input_params[p[0]] = [] unless @input_params.has_key?(p[0])
        @input_params[p[0]] << p[1]
        self
      end

      def set_input_params hash
        @input_params = hash
      end

      def add_output_param *param
        p = parse_param(param)
        ::Av.log "Adding output parameter #{p}"
        @output_params[p[0]] = [] unless @output_params.has_key?(p[0])
        @output_params[p[0]] << p[1]
        self
      end

      def set_output_params hash
        @output_params = hash
      end

      def run
        raise Av::CommandError if (@source.nil? && @destination.nil?) || @command_name.nil?

        parameters = []
        parameters << @command_name
        parameters << @default_params if @default_params
        if @input_params
          parameters << @input_params.to_s
        end
        parameters << %Q(-i "#{@source}") if @source
        if @output_params
          parameters << @output_params.to_s
        end
        parameters << %Q(-y "#{@destination}") if @destination
        command_line = parameters.flatten.compact.join(" ").strip.squeeze(" ")
        ::Av.run(command_line)
      end

      def identify path
        meta = {}
        command = %Q(#{@command_name} -i "#{File.expand_path(path)}" 2>&1)
        out = ::Av.run(command, [0,1])
        out.split("\n").each do |line|
          if line =~ /(([\d\.]*)\s.?)fps,/
            meta[:fps] = $1.to_i
          end
          # Matching lines like:
          # Video: h264, yuvj420p, 640x480 [PAR 72:72 DAR 4:3], 10301 kb/s, 30 fps, 30 tbr, 600 tbn, 600 tbc
          if line =~ /Video:(.*)/
            size = $1.to_s.match(/\d{3,5}x\d{3,5}/).to_s
            meta[:size] = size unless size.empty?
            if meta[:size]
              meta[:width], meta[:height] = meta[:size].split('x').map(&:to_i)
              meta[:aspect] = meta[:width].to_f / meta[:height].to_f
            end
          end
          # Matching Stream #0.0: Audio: libspeex, 8000 Hz, mono, s16
          if line =~ /Audio:(.*)/
            meta[:audio_encode], meta[:audio_bitrate], meta[:audio_channels] = $1.to_s.split(',').map(&:strip)
          end
          # Matching Duration: 00:01:31.66, start: 0.000000, bitrate: 10404 kb/s
          if line =~ /Duration:(\s.?(\d*):(\d*):(\d*\.\d*))/
            meta[:length] = $2.to_s + ":" + $3.to_s + ":" + $4.to_s
            meta[:duration] = $2.to_i * 3600 + $3.to_i * 60 + $4.to_f
          end
          if line =~ /rotate\s*:\s(\d*)/
            meta[:rotate] = $1.to_i
          end
        end
        if meta.empty?
          ::Av.log "Empty metadata from #{path}. Got the following output: #{out}"
        else
          return meta
        end
        nil
      end

      def output_format format
        @output_format = format
        case format.to_s
        when /jpg$/, /jpeg$/, /png$/, /gif$/ # Images
          add_output_param 'f', 'image2'
          add_output_param 'vframes', '1'
        when /webm$/ # WebM
          add_output_param 'f', 'webm'
          add_output_param 'acodec', 'libvorbis'
          add_output_param 'vcodec', 'libvpx'
        when /ogv$/ # Ogg Theora
          add_output_param 'f', 'ogg'
          add_output_param 'acodec', 'libvorbis'
          add_output_param 'vcodec', 'libtheora'
        when /mp4$/
          add_output_param 'acodec', 'aac'
          add_output_param 'strict', 'experimental'
        end
      end

      # Children should override the following methods
      def filter_rotate degrees
        raise ::Av::FilterNotImplemented, 'rotate'
      end

      # Children should override the following methods
      def filter_volume vol
        raise ::Av::FilterNotImplemented, 'volume'
      end

      # ffmpeg and avconf both have the same seeking params
      def filter_seek seek
        add_input_param ss: seek
        self
      end

      def parse_param param
        list = []
        if param.count == 2
          list = param
        elsif param.count == 1
          case param[0].class.to_s
          when 'Hash'
            list[0], list[1] = param[0].to_a.flatten!
          when 'Array'
            list = param[0]
          end
        end
        list
      end
    end
  end
end
