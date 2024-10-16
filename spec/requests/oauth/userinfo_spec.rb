# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Oauth Userinfo Endpoint' do
  include RoutingHelper

  describe 'GET /oauth/userinfo' do
    subject do
      get '/oauth/userinfo', headers: headers
    end

    let(:user)     { Fabricate(:user) }
    let(:account)  { user.account }
    let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
    let(:scopes)   { 'profile' }
    let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(:success)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to include({
        iss: root_url,
        sub: account_url(account),
        name: account.display_name,
        preferred_username: account.username,
        profile: short_account_url(account),
        picture: full_asset_url(account.unavailable? ? account.avatar.default_url : account.avatar_original_url),
      })
    end
  end
end
