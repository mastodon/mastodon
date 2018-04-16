module OEmbed
  
  # A generic OEmbed-related Error. The OEmbed library does its best to capture all internal
  # errors and wrap them in an OEmbed::Error class so that the error-handling code in your
  # application can more easily identify the source of errors.
  #
  # The following Classes inherit from OEmbed::Error
  # * OEmbed::FormatNotSupported
  # * OEmbed::NotFound
  # * OEmbed::ParseError
  # * OEmbed::UnknownFormat
  # * OEmbed::UnknownResponse
  class Error < StandardError
  end

  # This is a test
  class NotFound < OEmbed::Error # :nodoc:
    def to_s
      "No embeddable content at '#{super}'"
    end
  end

  class UnknownFormat < OEmbed::Error # :nodoc:
    def to_s
      "The provider doesn't support the '#{super}' format"
    end
  end

  class FormatNotSupported < OEmbed::Error # :nodoc:
    def to_s
      "This server doesn't have the correct libraries installed to support the '#{super}' format"
    end
  end

  class UnknownResponse < OEmbed::Error # :nodoc:
    def to_s
      "Got unknown response (#{super}) from server"
    end
  end

  class ParseError < OEmbed::Error # :nodoc:
    def to_s
      "There was an error parsing the server response (#{super})"
    end
  end
    
end
