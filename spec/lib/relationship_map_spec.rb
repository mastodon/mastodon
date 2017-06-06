# frozen_string_literal: true

require 'rails_helper'

describe RelationshipMap do
  let(:account) { Fabricate(:account) }
  subject { described_class.new([123], account) }

  describe '#following' do
    it 'returns hash with follows target_account_id set to true' do
      follow = Fabricate(:follow, account: account)
      result = described_class.new([123, follow.target_account_id], account).following

      expected = { follow.target_account_id => true }
      expect(result).to eq expected
    end
  end

  describe '#followed_by' do
    it 'returns hash with follows account_id set to true' do
      follow = Fabricate(:follow, target_account: account)
      result = described_class.new([123, follow.account_id], account).followed_by

      expected = { follow.account_id => true }
      expect(result).to eq expected
    end
  end

  describe '#blocking' do
    it 'returns hash with blocks target_account_id set to true' do
      block = Fabricate(:block, account: account)
      result = described_class.new([123, block.target_account_id], account).blocking

      expected = { block.target_account_id => true }
      expect(result).to eq expected
    end
  end

  describe '#muting' do
    it 'returns hash with mutes target_account_id set to true' do
      mute = Fabricate(:mute, account: account)
      result = described_class.new([123, mute.target_account_id], account).muting

      expected = { mute.target_account_id => true }
      expect(result).to eq expected
    end
  end

  describe '#requested' do
    it 'returns hash with follow_requests target_account_id set to true' do
      follow_request = Fabricate(:follow_request, account: account)
      result = described_class.new([123, follow_request.target_account_id], account).requested

      expected = { follow_request.target_account_id => true }
      expect(result).to eq expected
    end
  end

  describe '#domain_blocking' do
    it 'returns hash with accounts from domain blocks set to true' do
      domain_account = Fabricate(:account, domain: 'example.com')
      Fabricate(:account_domain_block, account: account, domain: 'example.com')
      result = described_class.new([123, domain_account.id], account).domain_blocking

      expected = { domain_account.id => true }
      expect(result).to eq expected
    end
  end
end
