module CharlockHolmes
  class EncodingDetector
    # Default length for which to scan content for NULL bytes
    DEFAULT_BINARY_SCAN_LEN = 1024*1024

    # Length for which to scan content for NULL bytes
    attr_accessor :binary_scan_length

    alias :strip_tags? :strip_tags

    def initialize(scan_len=DEFAULT_BINARY_SCAN_LEN)
      @binary_scan_length = scan_len
    end

    # Attempt to detect the encoding of this string
    #
    # NOTE: This will create a new CharlockHolmes::EncodingDetector instance on every call
    # as well as use the default binary scan length
    #
    # str      - a String, what you want to detect the encoding of
    # hint_enc - an optional String (like "UTF-8"), the encoding name which will
    #            be used as an additional hint to the charset detector
    #
    # Returns: a Hash with :encoding, :language, :type and :confidence
    def self.detect(str, hint_enc=nil)
      new.detect(str, hint_enc)
    end

    # Attempt to detect the encoding of this string, and return
    # a list with all the possible encodings that match it.
    #
    # NOTE: This will create a new CharlockHolmes::EncodingDetector instance on every call
    # as well as use the default binary scan length
    #
    # str      - a String, what you want to detect the encoding of
    # hint_enc - an optional String (like "UTF-8"), the encoding name which will
    #            be used as an additional hint to the charset detector
    #
    # Returns: an Array with zero or more Hashes,
    # each one of them with with :encoding, :language, :type and :confidence
    def self.detect_all(str, hint_enc=nil)
      new.detect_all(str, hint_enc)
    end

    # A mapping table of supported encoding names from EncodingDetector
    # which point to the corresponding supported encoding name in Ruby.
    # Like: {"UTF-8" => "UTF-8", "IBM420_rtl" => "ASCII-8BIT"}
    #
    # Note that encodings that can't be mapped between Charlock and Ruby will resolve
    # to "ASCII-8BIT".
    @encoding_table = {}

    def self.encoding_table
      @encoding_table
    end

    BINARY = 'binary'

    # Builds the ENCODING_TABLE hash by running through the list of supported encodings
    # in the ICU detection API and trying to map them to supported encodings in Ruby.
    # This is built dynamically so as to take advantage of ICU upgrades which may have
    # support for more encodings in the future.
    #
    # Returns nothing.
    def self.build_encoding_table
      supported_encodings.each do |name|
        @encoding_table[name] = begin
          ::Encoding.find(name).name
        rescue ArgumentError
          BINARY
        end
      end
    end
    build_encoding_table
  end
end
