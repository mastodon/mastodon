# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'account featured tags API' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts'

  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/accounts/:id/featured_tags' do
    subject do
      get "/api/v1/accounts/#{account.id}/featured_tags", headers: headers
    end

    before do
      account.featured_tags.create!(name: 'foo')
      account.featured_tags.create!(name: 'bar')
    end

    it 'returns the expected tags', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to contain_exactly(a_hash_including({
        name: 'bar',
        url: short_account_tag_url(username: account.username, tag: 'bar'),
      }), a_hash_including({
        name: 'foo',
        url: short_account_tag_url(username: account.username, tag: 'foo'),
      }))
    end

    context 'when the account is remote' do
      it 'returns the expected tags', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to contain_exactly(a_hash_including({
          name: 'bar',
          url: short_account_tag_url(username: account.pretty_acct, tag: 'bar'),
        }), a_hash_including({
          name: 'foo',
          url: short_account_tag_url(username: account.pretty_acct, tag: 'foo'),
        }))
      end
    end
  end
end
