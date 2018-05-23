# frozen_string_literal: true

require 'base64'
require 'jwt/decode'
require 'jwt/default_options'
require 'jwt/encode'
require 'jwt/error'
require 'jwt/signature'
require 'jwt/verify'

# JSON Web Token implementation
#
# Should be up to date with the latest spec:
# https://tools.ietf.org/html/rfc7519
module JWT
  include JWT::DefaultOptions

  module_function

  def encode(payload, key, algorithm = 'HS256', header_fields = {})
    encoder = Encode.new payload, key, algorithm, header_fields
    encoder.segments
  end

  def decode(jwt, key = nil, verify = true, custom_options = {}, &keyfinder)
    raise(JWT::DecodeError, 'Nil JSON web token') unless jwt

    merged_options = DEFAULT_OPTIONS.merge(custom_options)

    decoder = Decode.new jwt, verify
    header, payload, signature, signing_input = decoder.decode_segments
    decode_verify_signature(key, header, payload, signature, signing_input, merged_options, &keyfinder) if verify

    Verify.verify_claims(payload, merged_options) if verify

    raise(JWT::DecodeError, 'Not enough or too many segments') unless header && payload

    [payload, header]
  end

  def decode_verify_signature(key, header, payload, signature, signing_input, options, &keyfinder)
    algo, key = signature_algorithm_and_key(header, payload, key, &keyfinder)

    raise(JWT::IncorrectAlgorithm, 'An algorithm must be specified') if allowed_algorithms(options).empty?
    raise(JWT::IncorrectAlgorithm, 'Expected a different algorithm') unless allowed_algorithms(options).include?(algo)

    Signature.verify(algo, key, signing_input, signature)
  end

  def signature_algorithm_and_key(header, payload, key, &keyfinder)
    key = (keyfinder.arity == 2 ? yield(header, payload) : yield(header)) if keyfinder
    raise JWT::DecodeError, 'No verification key available' unless key
    [header['alg'], key]
  end

  def allowed_algorithms(options)
    if options.key?(:algorithm)
      [options[:algorithm]]
    else
      options[:algorithms] || []
    end
  end
end
