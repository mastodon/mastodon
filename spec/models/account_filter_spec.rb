# frozen_string_literal: true

require 'rails_helper'

describe AccountFilter do
  describe 'with empty params' do
    it 'excludes instance actor by default' do
      filter = described_class.new({})

      expect(filter.results).to eq Account.without_instance_actor
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = described_class.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with origin and by_domain interacting' do
    let!(:local_account) { Fabricate(:account, domain: nil) }
    let!(:remote_account_one) { Fabricate(:account, domain: 'example.org') }
    let(:remote_account_two) { Fabricate(:account, domain: 'other.domain') }

    it 'works with domain first and origin remote' do
      filter = described_class.new(by_domain: 'example.org', origin: 'remote')
      expect(filter.results).to match_array [remote_account_one]
    end

    it 'works with domain last and origin remote' do
      filter = described_class.new(origin: 'remote', by_domain: 'example.org')
      expect(filter.results).to match_array [remote_account_one]
    end

    it 'works with domain first and origin local' do
      filter = described_class.new(by_domain: 'example.org', origin: 'local')
      expect(filter.results).to match_array [local_account]
    end

    it 'works with domain last and origin local' do
      filter = described_class.new(origin: 'local', by_domain: 'example.org')
      expect(filter.results).to match_array [remote_account_one]
    end
  end
end
