# frozen_string_literal: true

Fabricator(:keypair) do
  account
  type        :rsa
  public_key  SigningKeysHelpers::PUBLIC_RSA_TEST_KEY
  expires_at  nil
  revoked     false

  after_build do |keypair|
    if keypair.account.local?
      keypair.private_key ||= SigningKeysHelpers::PRIVATE_RSA_TEST_KEY
      keypair.local_fragment ||= "##{Random.hex}"
    else
      keypair.uri ||= ActivityPub::TagManager.instance.key_uri_for(keypair.account)
    end
  end
end
