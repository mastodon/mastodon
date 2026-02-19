# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain Blocks Previews API' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:blocks' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account, user: user) }

  describe 'GET /api/v1/domain_blocks/preview' do
    subject { get '/api/v1/domain_blocks/preview', params: { domain: domain }, headers: headers }

    let(:domain) { 'host.example' }

    before do
      Fabricate :follow, account: account, target_account: Fabricate(:account, domain: domain)
      Fabricate :follow, target_account: account, account: Fabricate(:account, domain: domain)
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'

    it 'returns http success and follower counts' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include(followers_count: 1)
        .and include(following_count: 1)
    end
  end
end
