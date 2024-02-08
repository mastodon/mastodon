# frozen_string_literal: true

require 'rails_helper'

describe 'redirection confirmations' do
  let(:account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/foo', url: 'https://example.com/@foo') }
  let(:status)  { Fabricate(:status, account: account, uri: 'https://example.com/users/foo/statuses/1', url: 'https://example.com/@foo/1') }

  context 'when a logged out user visits a local page for a remote account' do
    it 'shows a confirmation page' do
      visit "/@#{account.pretty_acct}"

      # It explains about the redirect
      expect(page).to have_content(I18n.t('redirects.title', instance: 'cb6e6126.ngrok.io'))

      # It features an appropriate link
      expect(page).to have_link(account.url, href: account.url)
    end
  end

  context 'when a logged out user visits a local page for a remote status' do
    it 'shows a confirmation page' do
      visit "/@#{account.pretty_acct}/#{status.id}"

      # It explains about the redirect
      expect(page).to have_content(I18n.t('redirects.title', instance: 'cb6e6126.ngrok.io'))

      # It features an appropriate link
      expect(page).to have_link(status.url, href: status.url)
    end
  end
end
