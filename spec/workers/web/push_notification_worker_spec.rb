# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::PushNotificationWorker do
  subject { described_class.new }

  let(:endpoint) { 'https://updates.push.services.mozilla.com/push/v1/subscription-id' }
  let(:user) { Fabricate(:user) }
  let(:notification) { Fabricate(:notification) }
  let(:vapid_public_key) { 'BB37UCyc8LLX4PNQSe-04vSFvpUWGrENubUaslVFM_l5TxcGVMY0C3RXPeUJAQHKYlcOM2P4vTYmkoo0VZGZTM4=' }
  let(:vapid_private_key) { 'OPrw1Sum3gRoL4-DXfSCC266r-qfFSRZrnj8MgIhRHg=' }
  let(:vapid_key) { Webpush::VapidKey.from_keys(vapid_public_key, vapid_private_key) }
  let(:contact_email) { 'sender@example.com' }

  # Legacy values
  let(:p256dh) { 'BN4GvZtEZiZuqFxSKVZfSfluwKBD7UxHNBmWkfiZfCtgDE8Bwh-_MtLXbBxTBAWH9r7IPKL0lhdcaqtL1dfxU5E=' }
  let(:auth) { 'Q2BoAjC09xH3ywDLNJr-dA==' }
  let(:legacy_subscription) { Fabricate(:web_push_subscription, user_id: user.id, key_p256dh: p256dh, key_auth: auth, endpoint: endpoint, data: { alerts: { notification.type => true } }) }
  let(:legacy_payload) do
    {
      ciphertext: "+\xB8\xDBT}\x13\xB6\xDD.\xF9\xB0\xA7\xC8\xD2\x80\xFD\x99#\xF7\xAC\x83\xA4\xDB,\x1F\xB5\xB9w\x85>\xF7\xADr",
      salt: "X\x97\x953\xE4X\xF8_w\xE7T\x95\xC51q\xFE",
      server_public_key: "\x04\b-RK9w\xDD$\x16lFz\xF9=\xB4~\xC6\x12k\xF3\xF40t\xA9\xC1\fR\xC3\x81\x80\xAC\f\x7F\xE4\xCC\x8E\xC2\x88 n\x8BB\xF1\x9C\x14\a\xFA\x8D\xC9\x80\xA1\xDDyU\\&c\x01\x88#\x118Ua",
      shared_secret: "\t\xA7&\x85\t\xC5m\b\xA8\xA7\xF8B{1\xADk\xE1y'm\xEDE\xEC\xDD\xEDj\xB3$s\xA9\xDA\xF0",
    }
  end

  # Standard values, from RFC8291
  let(:std_p256dh) { 'BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4' }
  let(:std_auth) { 'BTBZMqHH6r4Tts7J_aSIgg' }
  let(:std_as_public) { 'BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8' }
  let(:std_as_private) { 'yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw' }
  let(:std_salt) { 'DGv6ra1nlYgDCS1FRnbzlw' }
  let(:std_subscription) { Fabricate(:web_push_subscription, user_id: user.id, key_p256dh: std_p256dh, key_auth: std_auth, endpoint: endpoint, standard: true, data: { alerts: { notification.type => true } }) }
  let(:std_input) { 'When I grow up, I want to be a watermelon' }
  let(:std_ciphertext) { 'DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN' }

  describe 'perform' do
    around do |example|
      original_private = Rails.configuration.x.vapid.private_key
      original_public = Rails.configuration.x.vapid.public_key
      Rails.configuration.x.vapid.private_key = vapid_private_key
      Rails.configuration.x.vapid.public_key = vapid_public_key
      example.run
      Rails.configuration.x.vapid.private_key = original_private
      Rails.configuration.x.vapid.public_key = original_public
    end

    before do
      Setting.site_contact_email = contact_email

      allow(JWT).to receive(:encode).and_return('jwt.encoded.payload')

      stub_request(:post, endpoint).to_return(status: 201, body: '')
    end

    it 'Legacy push calls the relevant service with the legacy headers' do
      allow(Webpush::Legacy::Encryption).to receive(:encrypt).and_return(legacy_payload)

      subject.perform(legacy_subscription.id, notification.id)

      expect(legacy_web_push_endpoint_request)
        .to have_been_made
    end

    # We allow subject stub to encrypt the same input than the RFC8291 example
    # rubocop:disable RSpec/SubjectStub
    it 'Standard push calls the relevant service with the standard headers' do
      # Mock server keys to match RFC example
      allow(OpenSSL::PKey::EC).to receive(:generate).and_return(std_as_keys)
      # Mock the random salt to match RFC example
      rand = Random.new
      allow(Random).to receive(:new).and_return(rand)
      allow(rand).to receive(:bytes).and_return(Webpush.decode64(std_salt))
      # Mock input to match RFC example
      allow(subject).to receive(:push_notification_json).and_return(std_input)

      subject.perform(std_subscription.id, notification.id)

      expect(standard_web_push_endpoint_request)
        .to have_been_made
    end
    # rubocop:enable RSpec/SubjectStub

    def legacy_web_push_endpoint_request
      a_request(
        :post,
        endpoint
      ).with(
        headers: {
          'Content-Encoding' => 'aesgcm',
          'Content-Type' => 'application/octet-stream',
          'Crypto-Key' => "dh=BAgtUks5d90kFmxGevk9tH7GEmvz9DB0qcEMUsOBgKwMf-TMjsKIIG6LQvGcFAf6jcmAod15VVwmYwGIIxE4VWE;p256ecdsa=#{vapid_public_key.delete('=')}",
          'Encryption' => 'salt=WJeVM-RY-F9351SVxTFx_g',
          'Ttl' => '172800',
          'Urgency' => 'normal',
          'Authorization' => 'WebPush jwt.encoded.payload',
          'Unsubscribe-URL' => %r{/api/web/push_subscriptions/},
        },
        body: "+\xB8\xDBT}\u0013\xB6\xDD.\xF9\xB0\xA7\xC8Ҁ\xFD\x99#\xF7\xAC\x83\xA4\xDB,\u001F\xB5\xB9w\x85>\xF7\xADr"
      )
    end

    def standard_web_push_endpoint_request
      a_request(
        :post,
        endpoint
      ).with(
        headers: {
          'Content-Encoding' => 'aes128gcm',
          'Content-Type' => 'application/octet-stream',
          'Ttl' => '172800',
          'Urgency' => 'normal',
          'Authorization' => "vapid t=jwt.encoded.payload,k=#{vapid_public_key.delete('=')}",
          'Unsubscribe-URL' => %r{/api/web/push_subscriptions/},
        },
        body: Webpush.decode64(std_ciphertext)
      )
    end

    def std_as_keys
      # VapidKey contains a method to retrieve EC keypair from
      # B64 raw keys, the keypair is stored in curve field
      Webpush::VapidKey.from_keys(std_as_public, std_as_private).curve
    end
  end
end
