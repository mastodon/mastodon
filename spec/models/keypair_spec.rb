# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keypair do
  describe '#keypair' do
    let(:keypair) { Fabricate(:keypair) }

    it 'returns an RSA key pair' do
      expect(keypair.keypair).to be_instance_of OpenSSL::PKey::RSA
    end
  end

  describe '#full_uri' do
    let(:keypair) { Fabricate(:keypair, account: account) }

    context 'with a remote account' do
      let(:account) { Fabricate(:remote_account) }

      it 'returns an HTTP URI equals to the stored URI' do
        expect(keypair.full_uri)
          .to start_with('https://')
          .and eq(keypair.uri)
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account) }

      it 'returns an HTTP URI starting with the account URI' do
        expect(keypair.full_uri)
          .to start_with(ActivityPub::TagManager.instance.uri_for(account))
      end
    end
  end

  describe 'from_keyid' do
    context 'when a key with the given key ID exists' do
      let(:account) { Fabricate(:account, domain: 'example.com') }
      let(:keypair) { Fabricate(:keypair, account: account) }

      it 'returns the expected Keypair' do
        expect(described_class.from_keyid(keypair.uri))
          .to eq keypair
      end
    end

    context 'when no key with the expected key ID exists but there is an account with the same ID and a legacy key' do
      let(:account) { Fabricate(:account, domain: 'example.com', legacy_keypair: true) }
      let(:keyid) { "#{ActivityPub::TagManager.instance.uri_for(account)}#main-rsa-key" }

      it 'returns the expected Keypair' do
        expect(described_class.from_keyid(keyid))
          .to have_attributes(
            account: account,
            type: 'rsa',
            uri: keyid
          )
      end
    end

    context 'when no key with the expected key ID exists but there is an account with the same ID and no key' do
      let(:account) { Fabricate(:account, domain: 'example.com') }
      let(:keyid) { "#{ActivityPub::TagManager.instance.uri_for(account)}#main-rsa-key" }

      it 'returns nil' do
        expect(described_class.from_keyid(keyid))
          .to be_nil
      end
    end

    context 'when no key with the expected key ID exists and no matching account exists' do
      let(:keyid) { 'https://example.com/alice#main-key' }

      it 'returns nil' do
        expect(described_class.from_keyid(keyid))
          .to be_nil
      end
    end
  end
end
