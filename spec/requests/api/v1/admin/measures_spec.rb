# frozen_string_literal: true

require 'rails_helper'

describe 'Admin Measures' do
  let(:user)    { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }
  let(:params) do
    {
      keys: %w(instance_accounts instance_follows instance_followers),
      instance_accounts: {
        domain: 'mastodon.social',
        include_subdomains: true,
      },
      instance_follows: {
        domain: 'mastodon.social',
        include_subdomains: true,
      },
      instance_followers: {
        domain: 'mastodon.social',
        include_subdomains: true,
      },
    }
  end

  describe 'GET /api/v1/admin/measures' do
    context 'when not authorized' do
      it 'returns http forbidden' do
        post '/api/v1/admin/measures', params: params

        expect(response)
          .to have_http_status(403)
      end
    end

    context 'with correct scope' do
      let(:scopes) { 'admin:read' }

      it 'returns http success and status json' do
        post '/api/v1/admin/measures', params: params, headers: headers

        expect(response)
          .to have_http_status(200)

        expect(body_as_json)
          .to be_an(Array)
      end
    end
  end
end
