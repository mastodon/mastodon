require 'charlock_holmes' unless defined? CharlockHolmes

class String
  # Attempt to detect the encoding of this string
  #
  # Returns: a Hash with :encoding, :language, :type and :confidence
  def detect_encoding(hint_enc=nil)
    detector = CharlockHolmes::EncodingDetector.new
    detector.detect(self, hint_enc)
  end

  # Attempt to detect the encoding of this string, and return
  # a list with all the possible encodings that match it.
  #
  # Returns: an Array with zero or more Hashes,
  #          each one of them with with :encoding, :language, :type and :confidence
  def detect_encodings(hint_enc=nil)
    detector = CharlockHolmes::EncodingDetector.new
    detector.detect_all(self, hint_enc)
  end

  if method_defined? :force_encoding
    # Attempt to detect the encoding of this string
    # then set the encoding to what was detected ala `force_encoding`
    #
    # Returns: self
    def detect_encoding!(hint_enc=nil)
      if detected = self.detect_encoding(hint_enc)
        self.force_encoding(detected[:ruby_encoding]) if detected[:ruby_encoding]
      end
      self
    end
  end
end
