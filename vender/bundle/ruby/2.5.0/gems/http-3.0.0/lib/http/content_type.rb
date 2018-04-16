# frozen_string_literal: true

module HTTP
  ContentType = Struct.new(:mime_type, :charset) do
    MIME_TYPE_RE = %r{^([^/]+/[^;]+)(?:$|;)}
    CHARSET_RE   = /;\s*charset=([^;]+)/i

    class << self
      # Parse string and return ContentType struct
      def parse(str)
        new mime_type(str), charset(str)
      end

      private

      # :nodoc:
      def mime_type(str)
        m = str.to_s[MIME_TYPE_RE, 1]
        m && m.strip.downcase
      end

      # :nodoc:
      def charset(str)
        m = str.to_s[CHARSET_RE, 1]
        m && m.strip.delete('"')
      end
    end
  end
end
