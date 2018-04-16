module RQRCode

  NUMERIC = ['0','1','2','3','4','5','6','7','8','9'].freeze

  class QRNumeric
    attr_reader :mode

    def initialize( data )
      @mode = QRMODE[:mode_number]

      raise QRCodeArgumentError, "Not a numeric string `#{data}`" unless QRNumeric.valid_data?(data)

      @data = data;
    end


    def get_length
      @data.size
    end

    def self.valid_data? data
      data.each_char do |s|
        return false if NUMERIC.index(s).nil?
      end
      true
    end


    def write( buffer)
      buffer.numeric_encoding_start(get_length)

      (@data.size).times do |i|
        if i % 3 == 0
          chars = @data[i, 3]
          bit_length = get_bit_length(chars.length)
          buffer.put( get_code(chars), bit_length )
        end
      end
    end

    private

    NUMBER_LENGTH = {
      3 => 10,
      2 => 7,
      1 => 4
    }.freeze

    def get_bit_length(length)
      NUMBER_LENGTH[length]
    end

    def get_code(chars)
      chars.to_i
    end
  end
end
