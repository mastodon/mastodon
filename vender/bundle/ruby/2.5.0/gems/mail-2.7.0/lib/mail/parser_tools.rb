module Mail
  # Extends each field parser with utility methods.
  module ParserTools #:nodoc:
    # Slice bytes from ASCII-8BIT data and mark as UTF-8.
    if 'string'.respond_to?(:force_encoding)
      def chars(data, from_bytes, to_bytes)
        data.slice(from_bytes..to_bytes).force_encoding(Encoding::UTF_8)
      end
    else
      def chars(data, from_bytes, to_bytes)
        data.slice(from_bytes..to_bytes)
      end
    end
  end
end
