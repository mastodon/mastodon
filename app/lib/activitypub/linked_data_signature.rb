# frozen_string_literal: true

class ActivityPub::LinkedDataSignature
  include JsonLdHelper

  CONTEXT = 'https://w3id.org/identity/v1'

  def initialize(json)
    @json = json.with_indifferent_access
  end

  def verify_account!
    return unless @json['signature'].is_a?(Hash)

    type        = @json['signature']['type']
    creator_uri = @json['signature']['creator']
    signature   = @json['signature']['signatureValue']

    return unless type == 'RsaSignature2017'

    creator = ActivityPub::TagManager.instance.uri_to_resource(creator_uri, Account)
    creator = ActivityPub::FetchRemoteKeyService.new.call(creator_uri) if creator&.public_key.blank?

    return if creator.nil?

    options_hash   = hash(@json['signature'].without('type', 'id', 'signatureValue').merge('@context' => CONTEXT))
    document_hash  = hash(@json.without('signature'))
    to_be_verified = options_hash + document_hash

    creator if creator.keypair.public_key.verify(OpenSSL::Digest.new('SHA256'), Base64.decode64(signature), to_be_verified)
  rescue OpenSSL::PKey::RSAError
    false
  end

  def sign!(creator, sign_with: nil)
    options = {
      'type'    => 'RsaSignature2017',
      'creator' => [ActivityPub::TagManager.instance.uri_for(creator), '#main-key'].join,
      'created' => Time.now.utc.iso8601,
    }

    options_hash  = hash(options.without('type', 'id', 'signatureValue').merge('@context' => CONTEXT))
    document_hash = hash(@json.without('signature'))
    to_be_signed  = options_hash + document_hash
    keypair       = sign_with.present? ? OpenSSL::PKey::RSA.new(sign_with) : creator.keypair

    signature = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), to_be_signed))

    @json.merge('signature' => options.merge('signatureValue' => signature))
  end

  private

  def hash(obj)
    Digest::SHA256.hexdigest(canonicalize(obj))
  end
end
