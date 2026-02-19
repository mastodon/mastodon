# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OStatus::TagManager do
  around do |example|
    original = Rails.configuration.x.local_domain
    example.run
    Rails.configuration.x.local_domain = original
  end

  describe '#unique_tag' do
    before { Rails.configuration.x.local_domain = 'mastodon.example' }

    it 'returns a unique tag' do
      expect(described_class.instance.unique_tag(Time.utc(2000), 12, 'Status')).to eq 'tag:mastodon.example,2000-01-01:objectId=12:objectType=Status'
    end
  end

  describe '#unique_tag_to_local_id' do
    before { Rails.configuration.x.local_domain = 'mastodon.example' }

    it 'returns the ID part' do
      expect(described_class.instance.unique_tag_to_local_id('tag:mastodon.example,2000-01-01:objectId=12:objectType=Status', 'Status')).to eql '12'
    end

    it 'returns nil if it is not local id' do
      expect(described_class.instance.unique_tag_to_local_id('tag:remote,2000-01-01:objectId=12:objectType=Status', 'Status')).to be_nil
    end

    it 'returns nil if it is not expected type' do
      expect(described_class.instance.unique_tag_to_local_id('tag:mastodon.example,2000-01-01:objectId=12:objectType=Block', 'Status')).to be_nil
    end

    it 'returns nil if it does not have object ID' do
      expect(described_class.instance.unique_tag_to_local_id('tag:mastodon.example,2000-01-01:objectType=Status', 'Status')).to be_nil
    end
  end

  describe '#local_id?' do
    before { Rails.configuration.x.local_domain = 'mastodon.example' }

    it 'returns true for a local ID' do
      expect(described_class.instance.local_id?('tag:mastodon.example;objectId=12:objectType=Status')).to be true
    end

    it 'returns false for a foreign ID' do
      expect(described_class.instance.local_id?('tag:foreign.tld;objectId=12:objectType=Status')).to be false
    end
  end

  describe '#uri_for' do
    subject { described_class.instance.uri_for(target) }

    context 'with comment object' do
      let(:target) { Fabricate(:status, created_at: '2000-01-01T00:00:00Z', reply: true) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :comment
        expect(subject).to eq target.uri
      end
    end

    context 'with note object' do
      let(:target) { Fabricate(:status, created_at: '2000-01-01T00:00:00Z', reply: false, thread: nil) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :note
        expect(subject).to eq target.uri
      end
    end

    context 'when person object' do
      let(:target) { Fabricate(:account, username: 'alice') }

      it 'returns the URL for account' do
        expect(target.object_type).to eq :person
        expect(subject).to eq "https://#{Rails.configuration.x.local_domain}/users/alice"
      end
    end
  end
end
