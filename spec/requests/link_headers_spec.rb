# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Link headers' do
  describe 'on the account show page' do
    let(:account) { Fabricate(:account, username: 'test') }

    it 'contains webfinger and activitypub urls in link header' do
      get short_account_path(username: account)

      expect(response)
        .to have_http_link_header('https://cb6e6126.ngrok.io/.well-known/webfinger?resource=acct%3Atest%40cb6e6126.ngrok.io').for(rel: 'lrdd', type: 'application/jrd+json')
        .and have_http_link_header('https://cb6e6126.ngrok.io/users/test').for(rel: 'alternate', type: 'application/activity+json')
    end
  end
end
