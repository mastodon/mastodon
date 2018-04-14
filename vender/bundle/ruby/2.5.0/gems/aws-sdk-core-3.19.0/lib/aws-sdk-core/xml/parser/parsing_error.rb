module Aws
  module Xml
    class Parser
      class ParsingError < RuntimeError

        def initialize(msg, line, column)
          super(msg)
        end

        # @return [Integer,nil]
        attr_reader :line

        # @return [Integer,nil]
        attr_reader :column

      end
    end
  end
end
