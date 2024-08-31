# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'account featured tags API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account)  { Fabricate(:account) }

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
      expect(response.parsed_body).to contain_exactly(a_hash_including({
        name: 'bar',
        url: "https://cb6e6126.ngrok.io/@#{account.username}/tagged/bar",
      }), a_hash_including({
        name: 'foo',
        url: "https://cb6e6126.ngrok.io/@#{account.username}/tagged/foo",
      }))
    end

    context 'when the account is remote' do
      it 'returns the expected tags', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body).to contain_exactly(a_hash_including({
          name: 'bar',
          url: "https://cb6e6126.ngrok.io/@#{account.pretty_acct}/tagged/bar",
        }), a_hash_including({
          name: 'foo',
          url: "https://cb6e6126.ngrok.io/@#{account.pretty_acct}/tagged/foo",
        }))
      end
    end
  end
end
