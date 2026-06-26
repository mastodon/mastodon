# frozen_string_literal: true

class Multibase
  # Multicodec uses a variable-length unsigned integer to tag
  # data. We precompute here the types we are interested about.
  # Registered types are available at https://github.com/multiformats/multicodec/blob/master/table.csv
  MULTICODEC_PREFIXES = {
    'rsa-pub': 0x1205,
    'ed25519-pub': 0xED,
  }.transform_values do |code|
    bytes = []

    while code > 127
      bytes << ((code & 0x7F) | 128)
      code >>= 7
    end

    bytes << code
    bytes.pack('C*')
  end.freeze

  def self.decode(string)
    raise ArgumentError if string.nil?

    case string[0]
    when 'u'
      Base64.urlsafe_decode64(string[1...])
    when 'z'
      Base58.base58_to_binary(string[1...], :bitcoin)
    else
      raise ArgumentError
    end
  end

  def self.decode_multicodec(string)
    binary = decode(string)

    MULTICODEC_PREFIXES.each do |tag, prefix|
      return [tag, binary[prefix.length..]] if binary.starts_with?(prefix)
    end

    raise ArgumentError
  end
end
