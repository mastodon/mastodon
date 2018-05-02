# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteProfile do
  let(:remote_profile) { RemoteProfile.new(body) }
  let(:body) do
    <<-XML.squish
      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:mastodon="http://mastodon.social/schema/1.0">
        <link rel="hub" href="http://example.com" />
        <author>
          <link rel="avatar" href="http://example.com/avatar" />
          <link rel="header" href="http://example.com/header" />
          <poco:displayName>John</poco:displayName>
          <poco:note>Hello</poco:note>
          <mastodon:scope>public</mastodon:scope>
        </author>
    XML
  end

  describe '.initialize' do
    it 'sets document' do
      expect(remote_profile.document).not_to be nil
    end
  end

  describe '#author' do
    it 'returns author' do
      expect(remote_profile.author).to be_a Oga::XML::Element
    end
  end

  describe '#hub_link' do
    it 'returns hub link' do
      expect(remote_profile.hub_link).to eq 'http://example.com'
    end
  end

  describe '#display_name' do
    it 'returns display name' do
      expect(remote_profile.display_name).to eq 'John'
    end
  end

  describe '#note' do
    it 'returns note' do
      expect(remote_profile.note).to eq 'Hello'
    end
  end

  describe '#scope' do
    it 'returns scope' do
      expect(remote_profile.scope).to eq 'public'
    end
  end

  describe '#avatar' do
    let(:author) { remote_profile.author }

    it 'returns avatar' do
      expect(remote_profile.avatar).to eq 'http://example.com/avatar'
    end
  end

  describe '#header' do
    it 'returns header' do
      expect(remote_profile.header).to eq 'http://example.com/header'
    end
  end

  describe '#locked?' do
    before do
      allow(remote_profile).to receive(:scope).and_return(scope)
    end

    subject { remote_profile.locked? }

    context 'scope is private' do
      let(:scope) { 'private' }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'scope is not private' do
      let(:scope) { 'public' }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end
end
