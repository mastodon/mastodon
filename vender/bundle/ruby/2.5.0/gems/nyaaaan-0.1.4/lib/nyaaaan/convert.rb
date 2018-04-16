module Nyaaaan
    class Convert
      attr_accessor :pattern
      attr_accessor :replaces
  
      def initialize(pattern, replaces)
        @pattern = pattern
        @replaces = replaces
      end
  
      def match(input)
        input.match(@pattern)
      end
  
      def convert(input)
        input
      end
    end
  end
