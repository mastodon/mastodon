# encoding: utf-8
# frozen_string_literal: true
require 'mail/encodings/transfer_encoding'

module Mail
  module Encodings
    # Identity encodings do no encoding/decoding and have a fixed cost:
    # 1 byte in -> 1 byte out.
    class Identity < TransferEncoding #:nodoc:
      def self.decode(str)
        str
      end

      def self.encode(str)
        str
      end

      # 1 output byte per input byte.
      def self.cost(str)
        1.0
      end
    end
  end
end
