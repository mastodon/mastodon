require 'java'

module UNF # :nodoc: all
  class Normalizer
    def initialize()
      @normalizer = java.text.Normalizer
    end

    def normalize(string, normalization_form)
      @normalizer.normalize(string, form(normalization_form))
    end

    private

    def form(symbol)
      case symbol
      when :nfc
        @normalizer::Form::NFC
      when :nfd
        @normalizer::Form::NFD
      when :nfkc
        @normalizer::Form::NFKC
      when :nfkd
        @normalizer::Form::NFKD
      else
        raise ArgumentError, "unknown normalization form: #{symbol.inspect}"
      end
    end
  end
end
