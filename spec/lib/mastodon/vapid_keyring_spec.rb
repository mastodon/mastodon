# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/vapid_keyring'

RSpec.describe Mastodon::VapidKeyring do
  describe 'an empty keyring' do
    let(:keyring) { described_class.new([]) }

    it 'returns nil for public_key' do
      expect(keyring.public_key).to be_nil
    end

    it 'returns nil for private_key' do
      expect(keyring.private_key).to be_nil
    end
  end

  describe 'a non-empty keyring' do
    let(:inactive_keypair) { Webpush::VapidKey.new }
    let(:active_keypair) { Webpush::VapidKey.new }
    let(:keyring) { described_class.new([inactive_keypair.private_key, active_keypair.private_key]) }

    it 'uses the last keypair for the public key' do
      expect(keyring.public_key).to eq(active_keypair.public_key)
    end

    it 'uses the last keypair for the private key' do
      expect(keyring.private_key).to eq(active_keypair.private_key)
    end
  end
end
