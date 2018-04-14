module Temple
  module Filters
    # Try to encode input string
    #
    # @api public
    class Encoding < Parser
      define_options encoding: 'utf-8'

      def call(s)
        if options[:encoding] && s.respond_to?(:encoding)
          old_enc = s.encoding
          s = s.dup if s.frozen?
          s.force_encoding(options[:encoding])
          # Fall back to old encoding if new encoding is invalid
          unless s.valid_encoding?
            s.force_encoding(old_enc)
            s.force_encoding(::Encoding::BINARY) unless s.valid_encoding?
          end
        end
        s
      end
    end
  end
end
