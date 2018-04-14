require 'av/commands/base'
require 'tempfile'

module Av
  module Commands
    class Ffmpeg < Base
      
      def initialize(options = {})
        super(options)
        @command_name = "ffmpeg"
        # TODO handle quite for ffmpeg
      end
      
      def filter_concat list
        index_file = Tempfile.new('ffmpeg-concat')
        File.open(index_file, 'w') do |file|
          list.each do |item|
            file.write("file '#{item}'\n")
          end
        end
        add_input_param concat: "-i #{index_file.path}"
        self
      end
      
      def filter_volume vol
        add_input_param af: "volume=#{vol}"
        self
      end
      
      def filter_rotate degrees
        raise ::Av::InvalidFilterParameter unless degrees % 90 == 0
        case degrees
          when 90
            add_input_param vf: 'transpose=1'
          when 180
            add_input_param vf: 'vflip,hflip'
          when 270
            add_input_param vf: 'transpose=2'
        end
        self
      end
    end
  end
end
