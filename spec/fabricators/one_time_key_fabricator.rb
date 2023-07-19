# frozen_string_literal: true

Fabricator(:one_time_key) do
  device { Fabricate.build(:device) }
  key_id { Faker::Alphanumeric.alphanumeric(number: 10) }
  key { Base64.strict_encode64(Ed25519::SigningKey.generate.verify_key.to_bytes) }

  signature do |attrs|
    signing_key = Ed25519::SigningKey.generate
    attrs[:device].update(fingerprint_key: Base64.strict_encode64(signing_key.verify_key.to_bytes))
    Base64.strict_encode64(signing_key.sign(attrs[:key]))
  end
end
