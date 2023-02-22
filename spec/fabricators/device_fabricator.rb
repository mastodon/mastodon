# frozen_string_literal: true

Fabricator(:device) do
  access_token
  account
  device_id        { Faker::Number.number(digits: 5) }
  name             { Faker::App.name }
  fingerprint_key  { Base64.strict_encode64(Ed25519::SigningKey.generate.verify_key.to_bytes) }
  identity_key     { Base64.strict_encode64(Ed25519::SigningKey.generate.verify_key.to_bytes) }
end
