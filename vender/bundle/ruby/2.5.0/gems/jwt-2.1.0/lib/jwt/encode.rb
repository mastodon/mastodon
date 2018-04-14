# frozen_string_literal: true

require 'json'

# JWT::Encode module
module JWT
  # Encoding logic for JWT
  class Encode
    attr_reader :payload, :key, :algorithm, :header_fields, :segments

    def self.base64url_encode(str)
      Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
    end

    def initialize(payload, key, algorithm, header_fields)
      @payload = payload
      @key = key
      @algorithm = algorithm
      @header_fields = header_fields
      @segments = encode_segments
    end

    private

    def encoded_header
      header = { 'alg' => @algorithm }.merge(@header_fields)
      Encode.base64url_encode(JSON.generate(header))
    end

    def encoded_payload
      raise InvalidPayload, 'exp claim must be an integer' if @payload && @payload.is_a?(Hash) && @payload.key?('exp') && !@payload['exp'].is_a?(Integer)
      Encode.base64url_encode(JSON.generate(@payload))
    end

    def encoded_signature(signing_input)
      if @algorithm == 'none'
        ''
      else
        signature = JWT::Signature.sign(@algorithm, signing_input, @key)
        Encode.base64url_encode(signature)
      end
    end

    def encode_segments
      header = encoded_header
      payload = encoded_payload
      signature = encoded_signature([header, payload].join('.'))
      [header, payload, signature].join('.')
    end
  end
end
