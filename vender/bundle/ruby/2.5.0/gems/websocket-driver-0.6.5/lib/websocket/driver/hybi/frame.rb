module WebSocket
  class Driver
    class Hybi

      class Frame
        attr_accessor :final,
                      :rsv1,
                      :rsv2,
                      :rsv3,
                      :opcode,
                      :masked,
                      :masking_key,
                      :length_bytes,
                      :length,
                      :payload
      end

    end
  end
end
