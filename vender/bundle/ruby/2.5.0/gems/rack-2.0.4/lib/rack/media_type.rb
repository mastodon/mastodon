module Rack
  # Rack::MediaType parse media type and parameters out of content_type string

  class MediaType
    SPLIT_PATTERN = %r{\s*[;,]\s*}

    class << self
      # The media type (type/subtype) portion of the CONTENT_TYPE header
      # without any media type parameters. e.g., when CONTENT_TYPE is
      # "text/plain;charset=utf-8", the media-type is "text/plain".
      #
      # For more information on the use of media types in HTTP, see:
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7
      def type(content_type)
        return nil unless content_type
        content_type.split(SPLIT_PATTERN, 2).first.downcase
      end

      # The media type parameters provided in CONTENT_TYPE as a Hash, or
      # an empty Hash if no CONTENT_TYPE or media-type parameters were
      # provided.  e.g., when the CONTENT_TYPE is "text/plain;charset=utf-8",
      # this method responds with the following Hash:
      #   { 'charset' => 'utf-8' }
      def params(content_type)
        return {} if content_type.nil?
        Hash[*content_type.split(SPLIT_PATTERN)[1..-1].
          collect { |s| s.split('=', 2) }.
          map { |k,v| [k.downcase, strip_doublequotes(v)] }.flatten]
      end

      private

        def strip_doublequotes(str)
          (str[0] == ?" && str[-1] == ?") ? str[1..-2] : str
        end
    end
  end
end
