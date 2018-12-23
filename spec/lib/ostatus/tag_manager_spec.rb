# frozen_string_literal: true

require 'rails_helper'

describe OStatus::TagManager do
  describe '#unique_tag' do
    it 'returns a unique tag' do
      expect(OStatus::TagManager.instance.unique_tag(Time.utc(2000), 12, 'Status')).to eq 'tag:cb6e6126.ngrok.io,2000-01-01:objectId=12:objectType=Status'
    end
  end

  describe '#unique_tag_to_local_id' do
    it 'returns the ID part' do
      expect(OStatus::TagManager.instance.unique_tag_to_local_id('tag:cb6e6126.ngrok.io,2000-01-01:objectId=12:objectType=Status', 'Status')).to eql '12'
    end

    it 'returns nil if it is not local id' do
      expect(OStatus::TagManager.instance.unique_tag_to_local_id('tag:remote,2000-01-01:objectId=12:objectType=Status', 'Status')).to eq nil
    end

    it 'returns nil if it is not expected type' do
      expect(OStatus::TagManager.instance.unique_tag_to_local_id('tag:cb6e6126.ngrok.io,2000-01-01:objectId=12:objectType=Block', 'Status')).to eq nil
    end

    it 'returns nil if it does not have object ID' do
      expect(OStatus::TagManager.instance.unique_tag_to_local_id('tag:cb6e6126.ngrok.io,2000-01-01:objectType=Status', 'Status')).to eq nil
    end
  end

  describe '#local_id?' do
    it 'returns true for a local ID' do
      expect(OStatus::TagManager.instance.local_id?('tag:cb6e6126.ngrok.io;objectId=12:objectType=Status')).to be true
    end

    it 'returns false for a foreign ID' do
      expect(OStatus::TagManager.instance.local_id?('tag:foreign.tld;objectId=12:objectType=Status')).to be false
    end
  end

  describe '#uri_for' do
    subject { OStatus::TagManager.instance.uri_for(target) }

    context 'comment object' do
      let(:target) { Fabricate(:status, created_at: '2000-01-01T00:00:00Z', reply: true) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :comment
        is_expected.to eq target.uri
      end
    end

    context 'note object' do
      let(:target) { Fabricate(:status, created_at: '2000-01-01T00:00:00Z', reply: false, thread: nil) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :note
        is_expected.to eq target.uri
      end
    end

    context 'person object' do
      let(:target) { Fabricate(:account, username: 'alice') }

      it 'returns the URL for account' do
        expect(target.object_type).to eq :person
        is_expected.to eq 'https://cb6e6126.ngrok.io/users/alice'
      end
    end
  end
end
