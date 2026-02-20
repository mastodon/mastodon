# frozen_string_literal: true

keypair     = OpenSSL::PKey::RSA.new(2048)
public_key  = keypair.public_key.to_pem
private_key = keypair.to_pem

Fabricator(:keypair) do
  account
  type        :rsa
  public_key  public_key
  expires_at  nil
  revoked     false

  after_build do |keypair|
    keypair.uri ||= ActivityPub::TagManager.instance.key_uri_for(keypair.account)
    keypair.private_key ||= private_key if keypair.account.local?
  end
end
