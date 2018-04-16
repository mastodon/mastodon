require 'unf/version'

module UNF
  autoload :Normalizer, 'unf/normalizer'
end

class String
  ascii_only =
    if method_defined?(:ascii_only?)
      'ascii_only?'
    else
      '/[^\x00-\x7f]/ !~ self'
    end

  # :method: to_nfc
  # Converts the string to NFC.

  # :method: to_nfd
  # Converts the string to NFD.

  # :method: to_nfkc
  # Converts the string to NFKC.

  # :method: to_nfkd
  # Converts the string to NFKD.

  [:nfc, :nfd, :nfkc, :nfkd].each { |form|
    eval %{
      def to_#{form.to_s}
        if #{ascii_only}
          self
        else
          UNF::Normalizer.normalize(self, #{form.inspect})
        end
      end
    }
  }
end
