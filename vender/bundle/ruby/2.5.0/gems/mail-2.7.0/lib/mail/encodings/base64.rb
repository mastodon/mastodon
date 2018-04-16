# encoding: utf-8
# frozen_string_literal: true
require 'mail/encodings/7bit'

module Mail
  module Encodings
    # Base64 encoding handles binary content at the cost of 4 output bytes
    # per input byte.
    class Base64 < SevenBit
      NAME = 'base64'
      PRIORITY = 3
      Encodings.register(NAME, self)

      def self.can_encode?(enc)
        true
      end

      def self.decode(str)
        RubyVer.decode_base64(str)
      end

      def self.encode(str)
        ::Mail::Utilities.binary_unsafe_to_crlf(RubyVer.encode_base64(str))
      end

      # 3 bytes in -> 4 bytes out
      def self.cost(str)
        4.0 / 3
      end

      # Ruby Base64 inserts newlines automatically, so it doesn't exceed
      # SMTP line length limits.
      def self.compatible_input?(str)
        true
      end
    end
  end
end
