# frozen_string_literal: true

class SignedRequest
  EXPIRATION_WINDOW_LIMIT = 12.hours
  CLOCK_SKEW_MARGIN       = 1.hour

  class HttpSignature
    REQUIRED_PARAMETERS = %w(keyId signature).freeze

    def initialize(request)
      @request = request
    end

    def key_id
      signature_params['keyId']
    end

    def missing_signature_parameters
      REQUIRED_PARAMETERS if REQUIRED_PARAMETERS.any? { |p| signature_params[p].blank? }
    end

    def algorithm_supported?
      %w(rsa-sha256 hs2019).include?(signature_algorithm)
    end

    def verified?(actor)
      signature = Base64.decode64(signature_params['signature'])
      compare_signed_string = build_signed_string(include_query_string: true)

      return true unless verify_signature(actor, signature, compare_signed_string).nil?

      compare_signed_string = build_signed_string(include_query_string: false)
      return true unless verify_signature(actor, signature, compare_signed_string).nil?

      false
    end

    def created_time
      if signature_algorithm == 'hs2019' && signature_params['created'].present?
        Time.at(signature_params['created'].to_i).utc
      elsif @request.headers['Date'].present?
        Time.httpdate(@request.headers['Date']).utc
      end
    rescue ArgumentError => e
      raise Mastodon::SignatureVerificationError, "Invalid Date header: #{e.message}"
    end

    def expires_time
      Time.at(signature_params['expires'].to_i).utc if signature_params['expires'].present?
    rescue ArgumentError => e
      raise Mastodon::SignatureVerificationError, "Invalid Date header: #{e.message}"
    end

    def verify_signature_strength!
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the Date header or (created) pseudo-header to be signed' unless signed_headers.include?('date') || signed_headers.include?('(created)')
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the Digest header or (request-target) pseudo-header to be signed' unless signed_headers.include?(HttpSignatureDraft::REQUEST_TARGET) || signed_headers.include?('digest')
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the Host header to be signed when doing a GET request' if @request.get? && !signed_headers.include?('host')
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the Digest header to be signed when doing a POST request' if @request.post? && !signed_headers.include?('digest')
    end

    def verify_body_digest!
      return unless signed_headers.include?('digest')
      raise Mastodon::SignatureVerificationError, 'Digest header missing' unless @request.headers.key?('Digest')

      digests = @request.headers['Digest'].split(',').map { |digest| digest.split('=', 2) }.map { |key, value| [key.downcase, value] }
      sha256  = digests.assoc('sha-256')
      raise Mastodon::SignatureVerificationError, "Mastodon only supports SHA-256 in Digest header. Offered algorithms: #{digests.map(&:first).join(', ')}" if sha256.nil?

      return if body_digest == sha256[1]

      digest_size = begin
        Base64.strict_decode64(sha256[1].strip).length
      rescue ArgumentError
        raise Mastodon::SignatureVerificationError, "Invalid Digest value. The provided Digest value is not a valid base64 string. Given digest: #{sha256[1]}"
      end

      raise Mastodon::SignatureVerificationError, "Invalid Digest value. The provided Digest value is not a SHA-256 digest. Given digest: #{sha256[1]}" if digest_size != 32

      raise Mastodon::SignatureVerificationError, "Invalid Digest value. Computed SHA-256 digest: #{body_digest}; given: #{sha256[1]}"
    end

    private

    def request_body
      @request_body ||= @request.raw_post
    end

    def signature_params
      @signature_params ||= SignatureParser.parse(@request.headers['Signature'])
    rescue SignatureParser::ParsingError
      raise Mastodon::SignatureVerificationError, 'Error parsing signature parameters'
    end

    def signature_algorithm
      signature_params.fetch('algorithm', 'hs2019')
    end

    def signed_headers
      signature_params.fetch('headers', signature_algorithm == 'hs2019' ? '(created)' : 'date').downcase.split
    end

    def verify_signature(actor, signature, compare_signed_string)
      true if actor.keypair.public_key.verify(OpenSSL::Digest.new('SHA256'), signature, compare_signed_string)
    rescue OpenSSL::PKey::RSAError
      nil
    end

    def build_signed_string(include_query_string: true)
      signed_headers.map do |signed_header|
        case signed_header
        when HttpSignatureDraft::REQUEST_TARGET
          if include_query_string
            "#{HttpSignatureDraft::REQUEST_TARGET}: #{@request.method.downcase} #{@request.original_fullpath}"
          else
            # Current versions of Mastodon incorrectly omit the query string from the (request-target) pseudo-header.
            # Therefore, temporarily support such incorrect signatures for compatibility.
            # TODO: remove eventually some time after release of the fixed version
            "#{HttpSignatureDraft::REQUEST_TARGET}: #{@request.method.downcase} #{@request.path}"
          end
        when '(created)'
          raise Mastodon::SignatureVerificationError, 'Invalid pseudo-header (created) for rsa-sha256' unless signature_algorithm == 'hs2019'
          raise Mastodon::SignatureVerificationError, 'Pseudo-header (created) used but corresponding argument missing' if signature_params['created'].blank?

          "(created): #{signature_params['created']}"
        when '(expires)'
          raise Mastodon::SignatureVerificationError, 'Invalid pseudo-header (expires) for rsa-sha256' unless signature_algorithm == 'hs2019'
          raise Mastodon::SignatureVerificationError, 'Pseudo-header (expires) used but corresponding argument missing' if signature_params['expires'].blank?

          "(expires): #{signature_params['expires']}"
        else
          "#{signed_header}: #{@request.headers[to_header_name(signed_header)]}"
        end
      end.join("\n")
    end

    def body_digest
      @body_digest ||= Digest::SHA256.base64digest(request_body)
    end

    def to_header_name(name)
      name.split('-').map(&:capitalize).join('-')
    end
  end

  class HttpMessageSignature
    REQUIRED_PARAMETERS = %w(keyid created).freeze

    def initialize(request)
      @request = request
      @signature = Linzer::Signature.build({
        'signature-input' => @request.headers['signature-input'],
        'signature' => @request.headers['signature'],
      })
      @message = Linzer::Message.new(@request.rack_request)
    end

    def key_id
      @signature.parameters['keyid']
    end

    def missing_signature_parameters
      REQUIRED_PARAMETERS if REQUIRED_PARAMETERS.any? { |p| @signature.parameters[p].blank? }
    end

    # This method can lie as we only support one specific algorith for now.
    # But HTTP Message Signatures do not need to specify an algorithm (as
    # this can be inferred from the key used). Using an unsupported
    # algorithm will fail anyway further down the line.
    def algorithm_supported?
      true
    end

    def verified?(actor)
      key = Linzer.new_rsa_v1_5_sha256_public_key(actor.public_key)

      Linzer.verify(key, @message, @signature)
    rescue Linzer::VerifyError
      false
    end

    def verify_signature_strength!
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the (created) parameter to be signed' if @signature.parameters['created'].blank?
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the @method and @target-uri derived components to be signed' unless @signature.components.include?('@method') && @signature.components.include?('@target-uri')
      raise Mastodon::SignatureVerificationError, 'Mastodon requires the Content-Digest header to be signed when doing a POST request' if @request.post? && !signed_headers.include?('content-digest')
    end

    def verify_body_digest!
      return unless signed_headers.include?('content-digest')
      raise Mastodon::SignatureVerificationError, 'Content-Digest header missing' if @message.header('content-digest').nil?

      digests = Starry.parse_dictionary(@message.header('content-digest'))
      raise Mastodon::SignatureVerificationError, "Mastodon only supports SHA-256 in Content-Digest header. Offered algorithms: #{digests.keys.join(', ')}" unless digests.key?('sha-256')

      received_digest = Base64.strict_encode64(digests['sha-256'].value)
      return if body_digest == received_digest

      raise Mastodon::SignatureVerificationError, "Invalid Digest value. Computed SHA-256 digest: #{body_digest}; given: #{received_digest}"
    rescue Starry::ParseError
      raise Mastodon::MalformedHeaderError, 'Content-Digest could not be parsed. It does not contain a valid RFC8941 dictionary.'
    end

    def created_time
      Time.at(@signature.parameters['created'].to_i).utc
    rescue ArgumentError => e
      raise Mastodon::SignatureVerificationError, "Invalid Date header: #{e.message}"
    end

    def expires_time
      Time.at(@signature.parameters['expires'].to_i).utc if @signature.parameters['expires'].present?
    rescue ArgumentError => e
      raise Mastodon::SignatureVerificationError, "Invalid Date header: #{e.message}"
    end

    private

    def request_body
      @request_body ||= @request.raw_post
    end

    def signed_headers
      @signed_headers ||= @signature.components.reject { |c| c.start_with?('@') }
    end

    def body_digest
      @body_digest ||= Digest::SHA256.base64digest(request_body)
    end

    def missing_required_signature_parameters?
      @signature.parameters['keyid'].blank?
    end
  end

  attr_reader :signature

  delegate :key_id, to: :signature

  def initialize(request)
    @signature =
      if request.headers['signature-input'].present?
        HttpMessageSignature.new(request)
      else
        HttpSignature.new(request)
      end
  end

  def verified?(actor)
    missing_signature_parameters = @signature.missing_signature_parameters
    raise Mastodon::SignatureVerificationError, "Incompatible request signature. #{missing_signature_parameters.to_sentence} are required" if missing_signature_parameters
    raise Mastodon::SignatureVerificationError, 'Unsupported signature algorithm (only rsa-sha256 and hs2019 are supported)' unless @signature.algorithm_supported?
    raise Mastodon::SignatureVerificationError, 'Signed request date outside acceptable time window' unless matches_time_window?

    @signature.verify_signature_strength!
    @signature.verify_body_digest!
    @signature.verified?(actor)
  end

  private

  def matches_time_window?
    created_time = @signature.created_time
    expires_time = @signature.expires_time

    expires_time ||= created_time + 5.minutes unless created_time.nil?
    expires_time = [expires_time, created_time + EXPIRATION_WINDOW_LIMIT].min unless created_time.nil?

    return false if created_time.present? && created_time > Time.now.utc + CLOCK_SKEW_MARGIN
    return false if expires_time.present? && Time.now.utc > expires_time + CLOCK_SKEW_MARGIN

    true
  end
end
