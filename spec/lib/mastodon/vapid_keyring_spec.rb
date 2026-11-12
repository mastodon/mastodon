# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/vapid_keyring'

RSpec.describe Mastodon::VapidKeyring do
  let(:inactive_keypair) { Webpush::VapidKey.new }
  let(:active_keypair) { Webpush::VapidKey.new }
  let(:keyring) { described_class.new([inactive_keypair.private_key], active_keypair.private_key) }

  describe 'an empty keyring' do
    let(:keyring) { described_class.new([], nil) }

    it 'returns nil for active_key' do
      expect(keyring.active_key).to be_nil
    end

    it 'returns nil for public_key' do
      expect(keyring.public_key).to be_nil
    end
  end

  describe 'active_key' do
    it 'uses the last keypair' do
      expect(keyring.active_key.private_key).to eq(active_keypair.private_key)
    end
  end

  describe 'public_key' do
    it 'uses the last keypair' do
      expect(keyring.public_key).to eq(active_keypair.public_key)
    end
  end

  describe 'lookup' do
    it 'returns the active key for nil' do
      expect(keyring.lookup(nil).private_key).to eq(active_keypair.private_key)
    end

    it 'returns an inactive key when found' do
      expect(keyring.lookup(inactive_keypair.public_key).private_key).to eq(inactive_keypair.private_key)
    end

    it 'returns nil when a key is not found' do
      expect(keyring.lookup('invalid_public_key')).to be_nil
    end
  end
end
