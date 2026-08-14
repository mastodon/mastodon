# frozen_string_literal: true

require_relative '../support/signing_keys_helpers'

Fabricator(:keypair) do
  account     { Fabricate(:account, keypairs: []) }
  type        :rsa
  public_key  SigningKeysHelpers::PUBLIC_RSA_TEST_KEY
  expires_at  nil
  revoked     false

  after_build do |keypair|
    if keypair.account.local?
      keypair.private_key ||= SigningKeysHelpers::PRIVATE_RSA_TEST_KEY
      keypair.local_fragment ||= "##{Random.hex}"
    else
      keypair.uri ||= "#{ActivityPub::TagManager.instance.uri_for(keypair.account)}##{Random.hex}"
    end
  end
end
