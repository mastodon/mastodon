# frozen_string_literal: true

class ActivityPub::LinkedDataSignature
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  def verify_account!
    return unless @json['signature'].is_a?(Hash)

    type        = @json['signature']['type']
    creator_uri = @json['signature']['creator']
    signature   = @json['signature']['signatureValue']

    return unless type == 'RsaSignature2017'

    creator   = ActivityPub::TagManager.instance.uri_to_resource(creator_uri, Account)
    creator ||= ActivityPub::FetchRemoteKeyService.new.call(creator_uri)

    return if creator.nil?

    options_hash   = Digest::SHA256.hexdigest(canonicalize(@json['signature'].without('type', 'id', 'signatureValue')))
    document_hash  = Digest::SHA256.hexdigest(canonicalize(@json.without('signature')))
    to_be_verified = options_hash + document_hash

    if creator.keypair.public_key.verify(OpenSSL::Digest::SHA256.new, signature, to_be_verified)
      creator
    end
  end
end
