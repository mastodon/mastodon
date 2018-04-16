module Puma
  # Provides an IO-like object that always appears to contain no data.
  # Used as the value for rack.input when the request has no body.
  #
  class NullIO
    def gets
      nil
    end

    def each
    end

    # Mimics IO#read with no data.
    #
    def read(count = nil, _buffer = nil)
      (count && count > 0) ? nil : ""
    end

    def rewind
    end

    def close
    end

    def size
      0
    end

    def eof?
      true
    end

    def sync=(v)
    end

    def puts(*ary)
    end

    def write(*ary)
    end
  end
end
