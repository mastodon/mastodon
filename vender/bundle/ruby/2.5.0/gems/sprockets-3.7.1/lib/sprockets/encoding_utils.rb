require 'base64'
require 'stringio'
require 'zlib'

module Sprockets
  # Internal: HTTP transport encoding and charset detecting related functions.
  # Mixed into Environment.
  module EncodingUtils
    extend self

    ## Binary encodings ##

    # Public: Use deflate to compress data.
    #
    # str - String data
    #
    # Returns a compressed String
    def deflate(str)
      deflater = Zlib::Deflate.new(
        Zlib::BEST_COMPRESSION,
        -Zlib::MAX_WBITS,
        Zlib::MAX_MEM_LEVEL,
        Zlib::DEFAULT_STRATEGY
      )
      deflater << str
      deflater.finish
    end

    # Internal: Unmarshal optionally deflated data.
    #
    # Checks leading marshal header to see if the bytes are uncompressed
    # otherwise inflate the data an unmarshal.
    #
    # str - Marshaled String
    # window_bits - Integer deflate window size. See ZLib::Inflate.new()
    #
    # Returns unmarshaled Object or raises an Exception.
    def unmarshaled_deflated(str, window_bits = -Zlib::MAX_WBITS)
      major, minor = str[0], str[1]
      if major && major.ord == Marshal::MAJOR_VERSION &&
          minor && minor.ord <= Marshal::MINOR_VERSION
        marshaled = str
      else
        begin
          marshaled = Zlib::Inflate.new(window_bits).inflate(str)
        rescue Zlib::DataError
          marshaled = str
        end
      end
      Marshal.load(marshaled)
    end

    # Public: Use gzip to compress data.
    #
    # str - String data
    #
    # Returns a compressed String
    def gzip(str)
      io = StringIO.new
      gz = Zlib::GzipWriter.new(io, Zlib::BEST_COMPRESSION)
      gz.mtime = 1
      gz << str
      gz.finish
      io.string
    end

    # Public: Use base64 to encode data.
    #
    # str - String data
    #
    # Returns a encoded String
    def base64(str)
      Base64.strict_encode64(str)
    end


    ## Charset encodings ##

    # Internal: Shorthand aliases for detecter functions.
    CHARSET_DETECT = {}

    # Internal: Mapping unicode encodings to byte order markers.
    BOM = {
      Encoding::UTF_32LE => [0xFF, 0xFE, 0x00, 0x00],
      Encoding::UTF_32BE => [0x00, 0x00, 0xFE, 0xFF],
      Encoding::UTF_8    => [0xEF, 0xBB, 0xBF],
      Encoding::UTF_16LE => [0xFF, 0xFE],
      Encoding::UTF_16BE => [0xFE, 0xFF]
    }

    # Public: Basic string detecter.
    #
    # Attempts to parse any Unicode BOM otherwise falls back to the
    # environment's external encoding.
    #
    # str - ASCII-8BIT encoded String
    #
    # Returns encoded String.
    def detect(str)
      str = detect_unicode_bom(str)

      # Attempt Charlock detection
      if str.encoding == Encoding::BINARY
        charlock_detect(str)
      end

      # Fallback to environment's external encoding
      if str.encoding == Encoding::BINARY
        str.force_encoding(Encoding.default_external)
      end

      str
    end
    CHARSET_DETECT[:default] = method(:detect)

    # Internal: Use Charlock Holmes to detect encoding.
    #
    # To enable this code path, require 'charlock_holmes'
    #
    # Returns encoded String.
    def charlock_detect(str)
      if defined? CharlockHolmes::EncodingDetector
        if detected = CharlockHolmes::EncodingDetector.detect(str)
          str.force_encoding(detected[:encoding]) if detected[:encoding]
        end
      end

      str
    end

    # Public: Detect Unicode string.
    #
    # Attempts to parse Unicode BOM and falls back to UTF-8.
    #
    # str - ASCII-8BIT encoded String
    #
    # Returns encoded String.
    def detect_unicode(str)
      str = detect_unicode_bom(str)

      # Fallback to UTF-8
      if str.encoding == Encoding::BINARY
        str.force_encoding(Encoding::UTF_8)
      end

      str
    end
    CHARSET_DETECT[:unicode] = method(:detect_unicode)

    # Public: Detect and strip BOM from possible unicode string.
    #
    # str - ASCII-8BIT encoded String
    #
    # Returns UTF 8/16/32 encoded String without BOM or the original String if
    # no BOM was present.
    def detect_unicode_bom(str)
      bom_bytes = str.byteslice(0, 4).bytes.to_a

      BOM.each do |encoding, bytes|
        if bom_bytes[0, bytes.size] == bytes
          str = str.dup
          str.force_encoding(Encoding::BINARY)
          str.slice!(0, bytes.size)
          str.force_encoding(encoding)
          return str
        end
      end

      return str
    end

    # Public: Detect and strip @charset from CSS style sheet.
    #
    # str - String.
    #
    # Returns a encoded String.
    def detect_css(str)
      str = detect_unicode_bom(str)

      if name = scan_css_charset(str)
        encoding = Encoding.find(name)
        str = str.dup
        str.force_encoding(encoding)
        len = "@charset \"#{name}\";".encode(encoding).size
        str.slice!(0, len)
        str
      end

      # Fallback to UTF-8
      if str.encoding == Encoding::BINARY
        str.force_encoding(Encoding::UTF_8)
      end

      str
    end
    CHARSET_DETECT[:css] = method(:detect_css)

    # Internal: @charset bytes
    CHARSET_START = [0x40, 0x63, 0x68, 0x61, 0x72, 0x73, 0x65, 0x74, 0x20, 0x22]
    CHARSET_SIZE  = CHARSET_START.size

    # Internal: Scan binary CSS string for @charset encoding name.
    #
    # str - ASCII-8BIT encoded String
    #
    # Returns encoding String name or nil.
    def scan_css_charset(str)
      buf = []
      i = 0

      str.each_byte.each do |byte|
        # Halt on line breaks
        break if byte == 0x0A || byte == 0x0D

        # Only ascii bytes
        next unless 0x0 < byte && byte <= 0xFF

        if i < CHARSET_SIZE
        elsif i == CHARSET_SIZE
          if buf == CHARSET_START
            buf = []
          else
            break
          end
        elsif byte == 0x22
          return buf.pack('C*')
        end

        buf << byte
        i += 1
      end

      nil
    end

    # Public: Detect charset from HTML document.
    #
    # Attempts to parse any Unicode BOM otherwise attempt Charlock detection
    # and finally falls back to the environment's external encoding.
    #
    # str - String.
    #
    # Returns a encoded String.
    def detect_html(str)
      str = detect_unicode_bom(str)

      # Attempt Charlock detection
      if str.encoding == Encoding::BINARY
        charlock_detect(str)
      end

      # Fallback to environment's external encoding
      if str.encoding == Encoding::BINARY
        str.force_encoding(Encoding.default_external)
      end

      str
    end
    CHARSET_DETECT[:html] = method(:detect_html)
  end
end
