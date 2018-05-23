# frozen_string_literal: true

require 'jwt/error'

module JWT
  # JWT verify methods
  class Verify
    DEFAULTS = {
      leeway: 0
    }.freeze

    class << self
      %w[verify_aud verify_expiration verify_iat verify_iss verify_jti verify_not_before verify_sub].each do |method_name|
        define_method method_name do |payload, options|
          new(payload, options).send(method_name)
        end
      end

      def verify_claims(payload, options)
        options.each do |key, val|
          next unless key.to_s =~ /verify/
          Verify.send(key, payload, options) if val
        end
      end
    end

    def initialize(payload, options)
      @payload = payload
      @options = DEFAULTS.merge(options)
    end

    def verify_aud
      return unless (options_aud = @options[:aud])

      aud = @payload['aud']
      raise(JWT::InvalidAudError, "Invalid audience. Expected #{options_aud}, received #{aud || '<none>'}") if ([*aud] & [*options_aud]).empty?
    end

    def verify_expiration
      return unless @payload.include?('exp')
      raise(JWT::ExpiredSignature, 'Signature has expired') if @payload['exp'].to_i <= (Time.now.to_i - exp_leeway)
    end

    def verify_iat
      return unless @payload.include?('iat')

      iat = @payload['iat']
      raise(JWT::InvalidIatError, 'Invalid iat') if !iat.is_a?(Numeric) || iat.to_f > (Time.now.to_f + iat_leeway)
    end

    def verify_iss
      return unless (options_iss = @options[:iss])

      iss = @payload['iss']

      return if Array(options_iss).map(&:to_s).include?(iss.to_s)

      raise(JWT::InvalidIssuerError, "Invalid issuer. Expected #{options_iss}, received #{iss || '<none>'}")
    end

    def verify_jti
      options_verify_jti = @options[:verify_jti]
      jti = @payload['jti']

      if options_verify_jti.respond_to?(:call)
        verified = options_verify_jti.arity == 2 ? options_verify_jti.call(jti, @payload) : options_verify_jti.call(jti)
        raise(JWT::InvalidJtiError, 'Invalid jti') unless verified
      elsif jti.to_s.strip.empty?
        raise(JWT::InvalidJtiError, 'Missing jti')
      end
    end

    def verify_not_before
      return unless @payload.include?('nbf')
      raise(JWT::ImmatureSignature, 'Signature nbf has not been reached') if @payload['nbf'].to_i > (Time.now.to_i + nbf_leeway)
    end

    def verify_sub
      return unless (options_sub = @options[:sub])
      sub = @payload['sub']
      raise(JWT::InvalidSubError, "Invalid subject. Expected #{options_sub}, received #{sub || '<none>'}") unless sub.to_s == options_sub.to_s
    end

    private

    def global_leeway
      @options[:leeway]
    end

    def exp_leeway
      @options[:exp_leeway] || global_leeway
    end

    def iat_leeway
      @options[:iat_leeway] || global_leeway
    end

    def nbf_leeway
      @options[:nbf_leeway] || global_leeway
    end
  end
end
