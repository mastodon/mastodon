require "securerandom"

module Fog
  class UUID
    class << self
      def uuid
        if supported?
          SecureRandom.uuid
        else
          ary = SecureRandom.random_bytes(16).unpack("NnnnnN")
          ary[2] = (ary[2] & 0x0fff) | 0x4000
          ary[3] = (ary[3] & 0x3fff) | 0x8000
          "%08x-%04x-%04x-%04x-%04x%08x" % ary
        end
      end

      def supported?
        SecureRandom.respond_to?(:uuid)
      end
    end
  end
end
