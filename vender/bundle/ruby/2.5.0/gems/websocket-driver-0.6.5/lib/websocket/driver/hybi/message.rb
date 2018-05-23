module WebSocket
  class Driver
    class Hybi

      class Message
        attr_accessor :rsv1,
                      :rsv2,
                      :rsv3,
                      :opcode,
                      :data

        def initialize
          @rsv1   = false
          @rsv2   = false
          @rsv3   = false
          @opcode = nil
          @data   = String.new('').force_encoding(BINARY)
        end

        def <<(frame)
          @rsv1   ||= frame.rsv1
          @rsv2   ||= frame.rsv2
          @rsv3   ||= frame.rsv3
          @opcode ||= frame.opcode
          @data   <<  frame.payload
        end
      end

    end
  end
end
