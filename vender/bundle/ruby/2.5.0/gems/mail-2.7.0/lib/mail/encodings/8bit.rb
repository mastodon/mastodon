# encoding: utf-8
# frozen_string_literal: true
require 'mail/encodings/binary'

module Mail
  module Encodings
    class EightBit < Binary
      NAME = '8bit'
      PRIORITY = 4
      Encodings.register(NAME, self)

      # Per RFC 2821 4.5.3.1, SMTP lines may not be longer than 1000 octets including the <CRLF>.
      def self.compatible_input?(str)
        !str.lines.find { |line| line.bytesize > 998 }
      end
    end
  end
end
