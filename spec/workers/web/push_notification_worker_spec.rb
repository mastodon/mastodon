# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::PushNotificationWorker do
  subject { described_class.new }

  let(:p256dh) { 'BN4GvZtEZiZuqFxSKVZfSfluwKBD7UxHNBmWkfiZfCtgDE8Bwh-_MtLXbBxTBAWH9r7IPKL0lhdcaqtL1dfxU5E=' }
  let(:auth) { 'Q2BoAjC09xH3ywDLNJr-dA==' }
  let(:endpoint) { 'https://updates.push.services.mozilla.com/push/v1/subscription-id' }
  let(:user) { Fabricate(:user) }
  let(:notification) { Fabricate(:notification) }
  let(:subscription) { Fabricate(:web_push_subscription, user_id: user.id, key_p256dh: p256dh, key_auth: auth, endpoint: endpoint, data: { alerts: { notification.type => true } }) }
  let(:vapid_public_key) { 'BB37UCyc8LLX4PNQSe-04vSFvpUWGrENubUaslVFM_l5TxcGVMY0C3RXPeUJAQHKYlcOM2P4vTYmkoo0VZGZTM4=' }
  let(:vapid_private_key) { 'OPrw1Sum3gRoL4-DXfSCC266r-qfFSRZrnj8MgIhRHg=' }
  let(:vapid_key) { Webpush::VapidKey.from_keys(vapid_public_key, vapid_private_key) }
  let(:contact_email) { 'sender@example.com' }
  let(:ciphertext) { "+\xB8\xDBT}\x13\xB6\xDD.\xF9\xB0\xA7\xC8\xD2\x80\xFD\x99#\xF7\xAC\x83\xA4\xDB,\x1F\xB5\xB9w\x85>\xF7\xADr" }
  let(:salt) { "X\x97\x953\xE4X\xF8_w\xE7T\x95\xC51q\xFE" }
  let(:server_public_key) { "\x04\b-RK9w\xDD$\x16lFz\xF9=\xB4~\xC6\x12k\xF3\xF40t\xA9\xC1\fR\xC3\x81\x80\xAC\f\x7F\xE4\xCC\x8E\xC2\x88 n\x8BB\xF1\x9C\x14\a\xFA\x8D\xC9\x80\xA1\xDDyU\\&c\x01\x88#\x118Ua" }
  let(:shared_secret) { "\t\xA7&\x85\t\xC5m\b\xA8\xA7\xF8B{1\xADk\xE1y'm\xEDE\xEC\xDD\xEDj\xB3$s\xA9\xDA\xF0" }
  let(:payload) { { ciphertext: ciphertext, salt: salt, server_public_key: server_public_key, shared_secret: shared_secret } }

  describe 'perform' do
    before do
      allow(subscription).to receive_messages(contact_email: contact_email, vapid_key: vapid_key)
      allow(Web::PushSubscription).to receive(:find).with(subscription.id).and_return(subscription)
      allow(Webpush::Encryption).to receive(:encrypt).and_return(payload)
      allow(JWT).to receive(:encode).and_return('jwt.encoded.payload')

      stub_request(:post, endpoint).to_return(status: 201, body: '')

      subject.perform(subscription.id, notification.id)
    end

    it 'calls the relevant service with the correct headers' do
      expect(a_request(:post, endpoint).with(headers: {
        'Content-Encoding' => 'aesgcm',
        'Content-Type' => 'application/octet-stream',
        'Crypto-Key' => "dh=BAgtUks5d90kFmxGevk9tH7GEmvz9DB0qcEMUsOBgKwMf-TMjsKIIG6LQvGcFAf6jcmAod15VVwmYwGIIxE4VWE;p256ecdsa=#{vapid_public_key.delete('=')}",
        'Encryption' => 'salt=WJeVM-RY-F9351SVxTFx_g',
        'Ttl' => '172800',
        'Urgency' => 'normal',
        'Authorization' => 'WebPush jwt.encoded.payload',
      }, body: "+\xB8\xDBT}\u0013\xB6\xDD.\xF9\xB0\xA7\xC8Ҁ\xFD\x99#\xF7\xAC\x83\xA4\xDB,\u001F\xB5\xB9w\x85>\xF7\xADr")).to have_been_made
    end
  end
end
