# frozen_string_literal: true

require 'rails_helper'

describe 'Link headers' do
  describe 'on the account show page' do
    let(:account) { Fabricate(:account, username: 'test') }

    before do
      get short_account_path(username: account)
    end

    it 'contains webfinger url in link header' do
      link_header = link_header_with_type('application/jrd+json')

      expect(link_header.href).to eq 'http://www.example.com/.well-known/webfinger?resource=acct%3Atest%40cb6e6126.ngrok.io'
      expect(link_header.attr_pairs.first).to eq %w(rel lrdd)
    end

    it 'contains activitypub url in link header' do
      link_header = link_header_with_type('application/activity+json')

      expect(link_header.href).to eq 'https://cb6e6126.ngrok.io/users/test'
      expect(link_header.attr_pairs.first).to eq %w(rel alternate)
    end

    def link_header_with_type(type)
      LinkHeader.parse(response.headers['Link'].to_s).links.find do |link|
        link.attr_pairs.any?(['type', type])
      end
    end
  end
end
