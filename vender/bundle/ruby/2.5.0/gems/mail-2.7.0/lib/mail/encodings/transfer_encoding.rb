# encoding: utf-8
# frozen_string_literal: true
module Mail
  module Encodings
    class TransferEncoding
      NAME = ''

      PRIORITY = -1

      # And encoding's superclass can always transport it since the
      # class hierarchy is arranged e.g. Base64 < 7bit < 8bit < Binary.
      def self.can_transport?(enc)
        enc && enc <= self
      end

      # Override in subclasses to indicate that they can encode text
      # that couldn't be directly transported, e.g. Base64 has 7bit output,
      # but it can encode binary.
      def self.can_encode?(enc)
        can_transport? enc
      end

      def self.cost(str)
        raise "Unimplemented"
      end

      def self.compatible_input?(str)
        true
      end

      def self.to_s
        self::NAME
      end

      def self.negotiate(message_encoding, source_encoding, str, allowed_encodings = nil)
        message_encoding = Encodings.get_encoding(message_encoding || '8bit')
        source_encoding  = Encodings.get_encoding(source_encoding)

        if message_encoding && source_encoding && message_encoding.can_transport?(source_encoding) && source_encoding.compatible_input?(str)
          source_encoding
        else
          renegotiate(message_encoding, source_encoding, str, allowed_encodings)
        end
      end

      def self.renegotiate(message_encoding, source_encoding, str, allowed_encodings = nil)
        encodings = Encodings.get_all.select do |enc|
          (allowed_encodings.nil? || allowed_encodings.include?(enc)) &&
            message_encoding.can_transport?(enc) &&
            enc.can_encode?(source_encoding)
        end

        lowest_cost(str, encodings)
      end

      def self.lowest_cost(str, encodings)
        best = nil
        best_cost = nil

        encodings.each do |enc|
          # If the current choice cannot be transported safely, give priority
          # to other choices but allow it to be used as a fallback.
          this_cost = enc.cost(str) if enc.compatible_input?(str)

          if !best_cost || (this_cost && this_cost < best_cost)
            best_cost = this_cost
            best = enc
          elsif this_cost == best_cost
            best = enc if enc::PRIORITY < best::PRIORITY
          end
        end

        best
      end
    end
  end
end
