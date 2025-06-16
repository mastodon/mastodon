# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'redirection confirmations' do
  let(:account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/foo', url: 'https://example.com/@foo') }
  let(:status)  { Fabricate(:status, account: account, uri: 'https://example.com/users/foo/statuses/1', url: 'https://example.com/@foo/1') }

  context 'when logged out' do
    describe 'a local page for a remote account' do
      it 'shows a confirmation page with relevant content' do
        visit "/@#{account.pretty_acct}"

        expect(page)
          .to have_content(redirect_title) # Redirect explanation
          .and have_link(account.url, href: account.url) # Appropriate account link
          .and have_css('body', class: 'app-body')
      end
    end

    describe 'a local page for a remote status' do
      it 'shows a confirmation page with relevant content' do
        visit "/@#{account.pretty_acct}/#{status.id}"

        expect(page)
          .to have_content(redirect_title) # Redirect explanation
          .and have_link(status.url, href: status.url) # Appropriate status link
          .and have_css('body', class: 'app-body')
      end
    end
  end

  def redirect_title
    I18n.t('redirects.title', instance: local_domain_uri.host)
  end
end
