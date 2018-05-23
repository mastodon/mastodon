module Temple
  module Generators
    # Implements an array buffer.
    #
    #   _buf = []
    #   _buf << "static"
    #   _buf << dynamic
    #   _buf
    #
    # @api public
    class Array < Generator
      def create_buffer
        "#{buffer} = []"
      end

      def return_buffer
        buffer
      end
    end
  end
end
