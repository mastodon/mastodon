# frozen_string_literal: true

# This is an implementation of https://codeberg.org/fediverse/fep/src/branch/main/fep/8b32/fep-8b32.md
class ActivityPub::ObjectIntegrityProof
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  def verify_actor!(proof_purpose: 'assertionMethod')
    return unless @json.is_a?(Hash) && @json['proof'].is_a?(Hash)

    proof = @json['proof']
    return unless proof['type'] == 'DataIntegrityProof' && proof['verificationMethod'].present? && proof['proofPurpose'] == proof_purpose

    return if proof['expires']&.to_datetime&.past?

    cryptosuite = proof['cryptosuite']
    key_uri = proof['verificationMethod']

    return unless cryptosuite == 'eddsa-jcs-2022' && proof['proofValue'].present?

    keypair = Keypair.from_keyid(key_uri)
    keypair = ActivityPub::FetchRemoteKeyService.new.call(key_uri) if keypair&.public_key.blank?
    return if keypair.nil? || !keypair.usable? || keypair.type != 'ed25519'

    keypair.actor if ActivityPub::ObjectIntegrityProof.verify_eddsa_jcs_2022(@json, keypair.keypair)
  rescue Multibase::Error, OpenSSL::PKey::PKeyError
    false
  end

  # https://www.w3.org/TR/vc-di-eddsa/#verify-proof-eddsa-jcs-2022
  def self.verify_eddsa_jcs_2022(document, keypair) # rubocop:disable Naming/VariableNumber
    unsecured_document = document.without('proof')
    proof_options = document['proof'].without('proofValue')
    proof_bytes = Multibase.decode(document['proof']['proofValue'])

    if proof_options['@context'].present?
      return unless unsecured_document['@context'].is_a?(Array)
      return unless unsecured_document['@context'][...proof_options['@context'].length] == proof_options['@context']

      # Step 4.2. from the aforementioned algorithm, it's useful when vocabulary necessary to the cryptosuite had to be added on top of the to-be-signed document
      unsecured_document['@context'] = proof_options['@context']
    end

    transformed_data = unsecured_document.to_json_c14n
    proof_config = proof_options.to_json_c14n

    to_be_verified = Digest::SHA256.digest(proof_config) + Digest::SHA256.digest(transformed_data)

    keypair.verify(nil, proof_bytes, to_be_verified)
  end
end
