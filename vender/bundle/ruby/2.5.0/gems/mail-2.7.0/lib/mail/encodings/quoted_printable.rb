# encoding: utf-8
# frozen_string_literal: true
require 'mail/encodings/7bit'

module Mail
  module Encodings
    class QuotedPrintable < SevenBit
      NAME='quoted-printable'

      PRIORITY = 2

      def self.can_encode?(enc)
        EightBit.can_encode? enc
      end

      # Decode the string from Quoted-Printable. Cope with hard line breaks
      # that were incorrectly encoded as hex instead of literal CRLF.
      def self.decode(str)
        str.gsub(/(?:=0D=0A|=0D|=0A)\r\n/, "\r\n").unpack("M*").first
      end

      def self.encode(str)
        [str].pack("M")
      end

      def self.cost(str)
        # These bytes probably do not need encoding
        c = str.count("\x9\xA\xD\x20-\x3C\x3E-\x7E")
        # Everything else turns into =XX where XX is a
        # two digit hex number (taking 3 bytes)
        total = (str.bytesize - c)*3 + c
        total.to_f/str.bytesize
      end

      # QP inserts newlines automatically and cannot violate the SMTP spec.
      def self.compatible_input?(str)
        true
      end

      private

      Encodings.register(NAME, self)
    end
  end
end
