require 'av/commands/base'

module Av
  module Commands
    class Avconv < Base
      
      def initialize(options = {})
        super(options)
        @command_name = 'avconv'
        @default_params['loglevel'] = 'quiet' unless options[:quiet] == false
      end
      
      def filter_concat list
        add_input_param i: "concat:#{list.join('\|')} -c copy"
        self
      end
      
      def filter_volume vol
        add_input_param af: "volume=volume=#{vol}"
        self
      end
      
      def filter_rotate degrees
        raise ::Av::InvalidFilterParameter unless degrees % 90 == 0
        case degrees
          when 90
            add_input_param vf: 'clock'
          when 180
            add_input_param vf: 'vflip,hflip'
          when 270
            add_input_param vf: 'cclock'
        end
      end
      
    end
  end
end
