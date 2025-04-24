# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::Provider do
  include ProviderRequestHelper

  describe '#capabilities' do
    subject { described_class.new(confirmed: true, capabilities:) }

    let(:capabilities) do
      [
        { 'id' => 'one', 'enabled' => false },
        { 'id' => 'two' },
      ]
    end

    it 'returns an array of `Fasp::Capability` objects' do
      expect(subject.capabilities).to all(be_a(Fasp::Capability))
    end
  end

  describe '#capabilities_attributes=' do
    subject { described_class.new(confirmed: true) }

    let(:capabilities_params) do
      {
        '0' => { 'id' => 'one', 'enabled' => '1' },
        '1' => { 'id' => 'two', 'enabled' => '0' },
        '2' => { 'id' => 'three' },
      }
    end

    it 'sets capabilities from nested form style hash' do
      subject.capabilities_attributes = capabilities_params

      expect(subject).to be_capability('one')
      expect(subject).to be_capability('two')
      expect(subject).to be_capability('three')
      expect(subject).to be_capability_enabled('one')
      expect(subject).to_not be_capability_enabled('two')
      expect(subject).to_not be_capability_enabled('three')
    end
  end

  describe '#capability?' do
    subject { described_class.new(confirmed:, capabilities:) }

    let(:capabilities) do
      [
        { 'id' => 'one', 'enabled' => false },
        { 'id' => 'two', 'enabled' => true },
      ]
    end

    context 'when the provider is not confirmed' do
      let(:confirmed) { false }

      it 'always returns false' do
        expect(subject.capability?('one')).to be false
        expect(subject.capability?('two')).to be false
      end
    end

    context 'when the provider is confirmed' do
      let(:confirmed) { true }

      it 'returns true for available and false for missing capabilities' do
        expect(subject.capability?('one')).to be true
        expect(subject.capability?('two')).to be true
        expect(subject.capability?('three')).to be false
      end
    end
  end

  describe '#capability_enabled?' do
    subject { described_class.new(confirmed:, capabilities:) }

    let(:capabilities) do
      [
        { 'id' => 'one', 'enabled' => false },
        { 'id' => 'two', 'enabled' => true },
      ]
    end

    context 'when the provider is not confirmed' do
      let(:confirmed) { false }

      it 'always returns false' do
        expect(subject).to_not be_capability_enabled('one')
        expect(subject).to_not be_capability_enabled('two')
      end
    end

    context 'when the provider is confirmed' do
      let(:confirmed) { true }

      it 'returns true for enabled and false for disabled or missing capabilities' do
        expect(subject).to_not be_capability_enabled('one')
        expect(subject).to be_capability_enabled('two')
        expect(subject).to_not be_capability_enabled('three')
      end
    end
  end

  describe '#server_private_key' do
    subject { Fabricate(:fasp_provider) }

    it 'returns an OpenSSL::PKey::PKey' do
      expect(subject.server_private_key).to be_a OpenSSL::PKey::PKey
    end
  end

  describe '#server_public_key_base64' do
    subject { Fabricate(:fasp_provider) }

    it 'returns the server public key base64 encoded' do
      expect(subject.server_public_key_base64).to eq 'T2RHkakkqAOWEMRYv9OY7LGsuIcAdmBlxuXOKax6sjw='
    end
  end

  describe '#provider_public_key_base64=' do
    subject { Fabricate(:fasp_provider) }

    it 'allows setting the provider public key from a base64 encoded raw key' do
      subject.provider_public_key_base64 = '9qgjOfWRhozWc9dwx5JmbshizZ7TyPBhYk9+b5tE3e4='

      expect(subject.provider_public_key_pem).to eq "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEA9qgjOfWRhozWc9dwx5JmbshizZ7TyPBhYk9+b5tE3e4=\n-----END PUBLIC KEY-----\n"
    end
  end

  describe '#provider_public_key' do
    subject { Fabricate(:fasp_provider) }

    it 'returns an OpenSSL::PKey::PKey' do
      expect(subject.provider_public_key).to be_a OpenSSL::PKey::PKey
    end
  end

  describe '#provider_public_key_raw' do
    subject { Fabricate(:fasp_provider) }

    it 'returns a string comprised of raw bytes' do
      expect(subject.provider_public_key_raw).to be_a String
      expect(subject.provider_public_key_raw.encoding).to eq Encoding::BINARY
    end
  end

  describe '#provider_public_key_fingerprint' do
    subject { Fabricate(:fasp_provider) }

    it 'returns a base64 encoded sha256 hash of the public key' do
      expect(subject.provider_public_key_fingerprint).to eq '/AmW9EMlVq4o+Qcu9lNfTE8Ss/v9+evMPtyj2R437qE='
    end
  end

  describe '#url' do
    subject { Fabricate(:fasp_provider, base_url: 'https://myprovider.example.com/fasp_base/') }

    it 'returns a full URL for a given path' do
      url = subject.url('/test_path')
      expect(url).to eq 'https://myprovider.example.com/fasp_base/test_path'
    end
  end

  describe '#update_info!' do
    subject { Fabricate(:fasp_provider, base_url: 'https://myprov.example.com/fasp/') }

    before do
      stub_provider_request(subject,
                            path: '/provider_info',
                            response_body: {
                              capabilities: [
                                { id: 'debug', version: '0.1' },
                              ],
                              contactEmail: 'newcontact@example.com',
                              fediverseAccount: '@newfedi@social.example.com',
                              privacyPolicy: 'https::///example.com/privacy',
                              signInUrl: 'https://myprov.example.com/sign_in',
                            })
    end

    context 'when setting confirm to `true`' do
      it 'updates the provider and marks it as `confirmed`' do
        subject.update_info!(confirm: true)

        expect(subject.contact_email).to eq 'newcontact@example.com'
        expect(subject.fediverse_account).to eq '@newfedi@social.example.com'
        expect(subject.privacy_policy).to eq 'https::///example.com/privacy'
        expect(subject.sign_in_url).to eq 'https://myprov.example.com/sign_in'
        expect(subject).to be_confirmed
        expect(subject).to be_persisted
      end
    end

    context 'when setting confirm to `false`' do
      it 'updates the provider but does not mark it as `confirmed`' do
        subject.update_info!

        expect(subject.contact_email).to eq 'newcontact@example.com'
        expect(subject.fediverse_account).to eq '@newfedi@social.example.com'
        expect(subject.privacy_policy).to eq 'https::///example.com/privacy'
        expect(subject.sign_in_url).to eq 'https://myprov.example.com/sign_in'
        expect(subject).to_not be_confirmed
        expect(subject).to be_persisted
      end
    end
  end
end
