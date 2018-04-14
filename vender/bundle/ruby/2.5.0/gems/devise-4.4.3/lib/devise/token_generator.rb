# frozen_string_literal: true

require 'openssl'

module Devise
  class TokenGenerator
    def initialize(key_generator, digest = "SHA256")
      @key_generator = key_generator
      @digest = digest
    end

    def digest(klass, column, value)
      value.present? && OpenSSL::HMAC.hexdigest(@digest, key_for(column), value.to_s)
    end

    def generate(klass, column)
      key = key_for(column)

      loop do
        raw = Devise.friendly_token
        enc = OpenSSL::HMAC.hexdigest(@digest, key, raw)
        break [raw, enc] unless klass.to_adapter.find_first({ column => enc })
      end
    end

    private

    def key_for(column)
      @key_generator.generate_key("Devise #{column}")
    end
  end
end
