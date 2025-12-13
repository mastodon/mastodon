# frozen_string_literal: true

Fabricator(:web_push_subscription, from: Web::PushSubscription) do
  endpoint   Faker::Internet.url
  key_p256dh do
    curve = OpenSSL::PKey::EC.generate('prime256v1')
    ecdh_key = curve.public_key.to_bn.to_s(2)
    Base64.urlsafe_encode64(ecdh_key)
  end
  key_auth { Base64.urlsafe_encode64(Random.new.bytes(16)) }
  user { Fabricate(:user) }
  access_token { |attrs| Fabricate.build(:accessible_access_token, resource_owner_id: attrs[:user].id) }
end
