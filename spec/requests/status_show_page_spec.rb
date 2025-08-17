# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Statuses' do
  describe 'GET /@:account_username/:id' do
    include AccountsHelper

    def site_hostname
      local_domain_uri.host
    end

    it 'has valid opengraph tags' do
      account = Fabricate(:account, username: 'alice', display_name: 'Alice')
      status = Fabricate(:status, account: account, text: 'Hello World')

      get "/@#{account.username}/#{status.id}"

      expect(head_link_icons.size).to eq(3) # Three favicons with sizes

      expect(head_meta_content('og:title')).to match "#{display_name(account)} (#{acct(account)})"
      expect(head_meta_content('og:type')).to eq 'article'
      expect(head_meta_content('og:published_time')).to eq status.created_at.iso8601
      expect(head_meta_content('og:url')).to eq short_account_status_url(account_username: account.username, id: status.id)
      expect(head_meta_exists('og:locale')).to be false
    end

    it 'has og:locale opengraph tag if the status has is written in a given language' do
      status_text = "Una prova d'estatus català"
      account = Fabricate(:account, username: 'alice', display_name: 'Alice')
      status = Fabricate(:status, account: account, text: status_text, language: 'ca')

      get "/@#{account.username}/#{status.id}"

      expect(head_meta_content('og:title')).to match "#{display_name(account)} (#{acct(account)})"
      expect(head_meta_content('og:type')).to eq 'article'
      expect(head_meta_content('og:published_time')).to eq status.created_at.iso8601
      expect(head_meta_content('og:url')).to eq short_account_status_url(account_username: account.username, id: status.id)

      expect(head_meta_exists('og:locale')).to be true
      expect(head_meta_content('og:locale')).to eq 'ca'
      expect(head_meta_content('og:description')).to eq status_text
    end

    def head_link_icons
      response
        .parsed_body
        .search('html head link[rel=icon]')
    end

    def head_meta_content(property)
      response
        .parsed_body
        .search("html head meta[property='#{property}']")
        .attr('content')
        .text
    end

    def head_meta_exists(property)
      !response
        .parsed_body
        .search("html head meta[property='#{property}']")
        .empty?
    end
  end
end
