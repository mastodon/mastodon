# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteProfile do
  let(:remote_profile) { RemoteProfile.new(body) }
  let(:body) do
    <<-XML
      <feed xmlns="http://www.w3.org/2005/Atom">
      <author>John</author>
    XML
  end

  describe '.initialize' do
    it 'calls Nokogiri::XML.parse' do
      expect(Nokogiri::XML).to receive(:parse).with(body, nil, 'utf-8')
      RemoteProfile.new(body)
    end

    it 'sets document' do
      remote_profile = RemoteProfile.new(body)
      expect(remote_profile).not_to be nil
    end
  end

  describe '#root' do
    let(:document) { remote_profile.document }

    it 'callse document.at_xpath' do
      expect(document).to receive(:at_xpath).with(
        '/atom:feed|/atom:entry',
        atom: OStatus::TagManager::XMLNS
      )

      remote_profile.root
    end
  end

  describe '#author' do
    let(:root) { remote_profile.root }

    it 'calls root.at_xpath' do
      expect(root).to receive(:at_xpath).with(
        './atom:author|./dfrn:owner',
        atom: OStatus::TagManager::XMLNS,
        dfrn: OStatus::TagManager::DFRN_XMLNS
      )

      remote_profile.author
    end
  end

  describe '#hub_link' do
    let(:root) { remote_profile.root }

    it 'calls #link_href_from_xml' do
      expect(remote_profile).to receive(:link_href_from_xml).with(root, 'hub')
      remote_profile.hub_link
    end
  end

  describe '#display_name' do
    let(:author) { remote_profile.author }

    it 'calls author.at_xpath.content' do
      expect(author).to receive_message_chain(:at_xpath, :content).with(
        './poco:displayName',
        poco: OStatus::TagManager::POCO_XMLNS
      ).with(no_args)

      remote_profile.display_name
    end
  end

  describe '#note' do
    let(:author) { remote_profile.author }

    it 'calls author.at_xpath.content' do
      expect(author).to receive_message_chain(:at_xpath, :content).with(
        './atom:summary|./poco:note',
        atom: OStatus::TagManager::XMLNS,
        poco: OStatus::TagManager::POCO_XMLNS
      ).with(no_args)

      remote_profile.note
    end
  end

  describe '#scope' do
    let(:author) { remote_profile.author }

    it 'calls author.at_xpath.content' do
      expect(author).to receive_message_chain(:at_xpath, :content).with(
        './mastodon:scope',
        mastodon: OStatus::TagManager::MTDN_XMLNS
      ).with(no_args)

      remote_profile.scope
    end
  end

  describe '#avatar' do
    let(:author) { remote_profile.author }

    it 'calls #link_href_from_xml' do
      expect(remote_profile).to receive(:link_href_from_xml).with(author, 'avatar')
      remote_profile.avatar
    end
  end

  describe '#header' do
    let(:author) { remote_profile.author }

    it 'calls #link_href_from_xml' do
      expect(remote_profile).to receive(:link_href_from_xml).with(author, 'header')
      remote_profile.header
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
