module Temple
  module Filters
    # Remove BOM from input string
    #
    # @api public
    class RemoveBOM < Parser
      def call(s)
        return s if s.encoding.name !~ /^UTF-(8|16|32)(BE|LE)?/
        s.gsub(Regexp.new("\\A\uFEFF".encode(s.encoding.name)), ''.freeze)
      end
    end
  end
end
