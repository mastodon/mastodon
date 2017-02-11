require 'rails_helper'

RSpec.describe TagManager do
  let(:local_domain) { Rails.configuration.x.local_domain }

  describe '#unique_tag' do
    it 'returns a string' do
      expect(TagManager.instance.unique_tag(Time.now, 12, 'Status')).to be_a String
    end
  end

  describe '#unique_tag_to_local_id' do
    it 'returns the ID part' do
      expect(TagManager.instance.unique_tag_to_local_id("tag:#{local_domain};objectId=12:objectType=Status", 'Status')).to eql '12'
    end
  end

  describe '#local_id?' do
    it 'returns true for a local ID' do
      expect(TagManager.instance.local_id?("tag:#{local_domain};objectId=12:objectType=Status")).to be true
    end

    it 'returns false for a foreign ID' do
      expect(TagManager.instance.local_id?('tag:foreign.tld;objectId=12:objectType=Status')).to be false
    end
  end

  describe '#uri_for' do
    let(:alice)  { Fabricate(:account, username: 'alice') }
    let(:bob)    { Fabricate(:account, username: 'bob') }
    let(:status) { Fabricate(:status, text: 'Hello world', account: alice) }

    subject { TagManager.instance.uri_for(target) }

    context 'Account' do
      let(:target) { alice }

      it 'returns a string' do
        expect(subject).to be_a String
      end
    end

    context 'Status' do
      let(:target) { status }

      it 'returns a string' do
        expect(subject).to be_a String
      end
    end
  end

  describe '#url_for' do
    let(:alice)  { Fabricate(:account, username: 'alice') }
    let(:bob)    { Fabricate(:account, username: 'bob') }
    let(:status) { Fabricate(:status, text: 'Hello world', account: alice) }

    subject { TagManager.instance.url_for(target) }

    context 'Account' do
      let(:target) { alice }

      it 'returns a URL' do
        expect(subject).to be_a String
      end
    end

    context 'Status' do
      let(:target) { status }

      it 'returns a URL' do
        expect(subject).to be_a String
      end
    end
  end
end
