module WebSocket
  module Mask
    def self.mask(payload, mask)
      return payload if mask.nil? || payload.empty?

      payload.tap do |result|
        payload.bytesize.times do |i|
          result.setbyte(i, payload.getbyte(i) ^ mask.getbyte(i % 4))
        end
      end
    end

  end
end
